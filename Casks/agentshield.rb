cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1341"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1341/agentshield_0.2.1341_darwin_amd64.tar.gz"
      sha256 "5c1326c715a315fdeebe44a0eaab657a3c79c5271a8d53f7d01b30dac71e7381"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1341/agentshield_0.2.1341_darwin_arm64.tar.gz"
      sha256 "99bd9e6d38d643614fe23293ed48d14e60a598135188a5f2a2ff338546528e18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1341/agentshield_0.2.1341_linux_amd64.tar.gz"
      sha256 "cd420a12f32fd35bafb83a0179bfa0febd0caa7bca1009ccd9c784119b9eee66"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1341/agentshield_0.2.1341_linux_arm64.tar.gz"
      sha256 "8dc1e54acd90aad31eff18f10c26458666dcff61c946b2dde9c319f373fb55a2"
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
