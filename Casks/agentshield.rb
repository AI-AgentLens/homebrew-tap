cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1462"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1462/agentshield_0.2.1462_darwin_amd64.tar.gz"
      sha256 "6522cf7e180a36952aa14da9364e8f6a48a7ed9e64c00d54edbc15d74c515db2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1462/agentshield_0.2.1462_darwin_arm64.tar.gz"
      sha256 "56e1f1c069f9733485438f03cc47d4a2b635e1185720221b44ff1424fbbd9142"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1462/agentshield_0.2.1462_linux_amd64.tar.gz"
      sha256 "0c1b664f528928d05218d888c3ae702f52f78de53b35bdabe70f7ee1bb864e91"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1462/agentshield_0.2.1462_linux_arm64.tar.gz"
      sha256 "72acdc1c6d7dd8aa653876c2bd63e01ae868d75ac3b6930f84576f72288129a8"
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
