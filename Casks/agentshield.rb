cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2027"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2027/agentshield_0.2.2027_darwin_amd64.tar.gz"
      sha256 "1c78f80fed9e52d4322fdfe2a9f73bf0c5639876f3b56b574c7f0c4a97c91b10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2027/agentshield_0.2.2027_darwin_arm64.tar.gz"
      sha256 "256adffc5c87904a02366a7be8f1280179bec7811dd0625d150bf9cce8685d7a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2027/agentshield_0.2.2027_linux_amd64.tar.gz"
      sha256 "b213a74a683a054d16ae15f936e2549a6d103698f5494ca863be310527ec5e24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2027/agentshield_0.2.2027_linux_arm64.tar.gz"
      sha256 "4300fc75ae6e9db3ae541a6078e56178798cc6d1b1591f6a32fdbdb1c51bffb6"
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
