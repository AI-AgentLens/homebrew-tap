cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1488"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1488/agentshield_0.2.1488_darwin_amd64.tar.gz"
      sha256 "b276ef6a11d0ea0ae0f39caabb61218858457506c777ad45eb995c241865ed64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1488/agentshield_0.2.1488_darwin_arm64.tar.gz"
      sha256 "8d39b60c69e6d8d4af5bb4eaf901dff69c27238c04e85945a4958def8985199a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1488/agentshield_0.2.1488_linux_amd64.tar.gz"
      sha256 "ddd5c824dc56f5a025072eb04af3d44e67d07f415109da1c932cc9be139e9f17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1488/agentshield_0.2.1488_linux_arm64.tar.gz"
      sha256 "aab551f0249f36178ee6228f600c06bf238f9ff744cdfdbde12898e51aa1113d"
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
