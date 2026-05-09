cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.927"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.927/agentshield_0.2.927_darwin_amd64.tar.gz"
      sha256 "708466e9ad14ed3f79dacd3b97ba2cca740abbaff95de253d5c509b2c445be49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.927/agentshield_0.2.927_darwin_arm64.tar.gz"
      sha256 "994105c9de9072b4399e93aaf0e5297d21da10c556ca40d6be929fcf9da50252"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.927/agentshield_0.2.927_linux_amd64.tar.gz"
      sha256 "5fe20a02d08125f2af60053eb1bbb56c17cc7a92b0c34a953213c3944bbdd3aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.927/agentshield_0.2.927_linux_arm64.tar.gz"
      sha256 "6e8e0155ffc18e722cbdfd2156cb4cf2d9a09c60890c1cfa57afac8836333a1a"
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
