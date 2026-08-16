cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1883"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1883/agentshield_0.2.1883_darwin_amd64.tar.gz"
      sha256 "6f3cf6a678b371fd86a4710b437e5314ebafdcf69f73c965db7ceae83bdf4d00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1883/agentshield_0.2.1883_darwin_arm64.tar.gz"
      sha256 "edf84d148149633b05da2feb9192d5889baaa2608c18c4e47b0e5566edc2573a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1883/agentshield_0.2.1883_linux_amd64.tar.gz"
      sha256 "ac7c8747cbd78f4892529e977669aee43ecf3d3ac14b20cdb348c03c935d042d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1883/agentshield_0.2.1883_linux_arm64.tar.gz"
      sha256 "a63e4ebdb931a3e14c498d56b949ceb96d2c212964716f5d7408bada2b00d737"
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
