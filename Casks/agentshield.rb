cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1453"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1453/agentshield_0.2.1453_darwin_amd64.tar.gz"
      sha256 "9104c80e01d04ef12fded935e72d755ba2c4b2f87e8f3c4a2d53ec20c01830c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1453/agentshield_0.2.1453_darwin_arm64.tar.gz"
      sha256 "7261d16afc5c951154157350250cef04e7c23f21e3c1023070cf8b26d5f5d02a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1453/agentshield_0.2.1453_linux_amd64.tar.gz"
      sha256 "8ddc1a4bd76689d6b6f41d45855485558a50e4b9e7fc14849e95a1d8a9abf72b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1453/agentshield_0.2.1453_linux_arm64.tar.gz"
      sha256 "b83bd0afbbb4bb9c2e0682a6e167481c1dea4f429d037b1aab691a9551b97c5f"
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
