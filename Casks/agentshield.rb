cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1522"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1522/agentshield_0.2.1522_darwin_amd64.tar.gz"
      sha256 "a090ab8b87c9d542e88193f59fb94daa2d877ac72bad065c9048e6de177ceadd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1522/agentshield_0.2.1522_darwin_arm64.tar.gz"
      sha256 "811f9ad4ca07b72ed64dea87cbccbfa239eef7c5aa78fe0ead9ffa1db7c5b9c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1522/agentshield_0.2.1522_linux_amd64.tar.gz"
      sha256 "2bb5ebabf94520be7ec718684b6431502254c93d7a131dda490e84b0de19c4f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1522/agentshield_0.2.1522_linux_arm64.tar.gz"
      sha256 "1011d07d32e4b2db15f7d8a2e211caccae9c5742775b3ccbebbaabb56e609cb5"
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
