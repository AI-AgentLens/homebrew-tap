cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1833"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1833/agentshield_0.2.1833_darwin_amd64.tar.gz"
      sha256 "27aff79304a99c3be2415215d0c92b0e8464b9d2fb3a9b4c91927060e1093307"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1833/agentshield_0.2.1833_darwin_arm64.tar.gz"
      sha256 "b9a8b4a4c7cafeb3d41a9a4f39b197fe78874e2b5b167e2a2316120606ad2e39"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1833/agentshield_0.2.1833_linux_amd64.tar.gz"
      sha256 "894032c9acbfcb2d2bfdcd51b6accbfd79aaab8316eade98fcf5e609d2d7d581"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1833/agentshield_0.2.1833_linux_arm64.tar.gz"
      sha256 "af2dd01c92ca834171ac639c85032f8cfaba3d34ce6c444fc913a70ceac28a37"
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
