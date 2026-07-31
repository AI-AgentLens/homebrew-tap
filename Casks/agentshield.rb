cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1764"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1764/agentshield_0.2.1764_darwin_amd64.tar.gz"
      sha256 "dab0d8fd7f9d7eaa9707a64a918f3967d7f72095ff3164d8bbf44b2a489d08ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1764/agentshield_0.2.1764_darwin_arm64.tar.gz"
      sha256 "88d6e48ed7a624edb9c534486029dc527090b6189723788fb727e3bf315d8a26"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1764/agentshield_0.2.1764_linux_amd64.tar.gz"
      sha256 "b745752d4f55e448d33795ce0c44877798610874854be8eca44aeb148a0b28a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1764/agentshield_0.2.1764_linux_arm64.tar.gz"
      sha256 "be5912dc18bc28ae6beb7e42954af5c87c1ed46b7865d3acb0b31a4dd3e99826"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
