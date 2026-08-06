cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1798"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1798/agentshield_0.2.1798_darwin_amd64.tar.gz"
      sha256 "42155af36a0c91ad080febf58b77b66fdbd60e9ddadc1eeb864cd8434d661290"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1798/agentshield_0.2.1798_darwin_arm64.tar.gz"
      sha256 "181c44b11d81a048bfe616e90870070344c4bc8dbecbf5f653b3f88309e45388"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1798/agentshield_0.2.1798_linux_amd64.tar.gz"
      sha256 "3637a7093273ad6c47a69fdedee3aa909db0224be0cbfcce7efe7c63614678b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1798/agentshield_0.2.1798_linux_arm64.tar.gz"
      sha256 "c8713fd26b43cbe218ad666e5f1554fd87aaa3ba51b4393c025ae04da6a3ff32"
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
