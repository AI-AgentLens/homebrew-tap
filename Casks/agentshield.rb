cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1225"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1225/agentshield_0.2.1225_darwin_amd64.tar.gz"
      sha256 "6fb1370cf440d175279bbbae2c426de339f37d64fa7e866cfc5fb4403305b2fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1225/agentshield_0.2.1225_darwin_arm64.tar.gz"
      sha256 "3cd9b51c8ac7b4e55d63e6717e169a067ef4b63b098449995e57d5ec3d3bfca4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1225/agentshield_0.2.1225_linux_amd64.tar.gz"
      sha256 "95024920268c061e9e1f4721166058f6c3f09b9c1d764178c45c81e48cf046de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1225/agentshield_0.2.1225_linux_arm64.tar.gz"
      sha256 "99f046eeb5671c449b79b1b4ef250ed1735d3ce4c48ed1671810d6b3228513bd"
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
