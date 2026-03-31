cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.264"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.264/agentshield_0.2.264_darwin_amd64.tar.gz"
      sha256 "93afe9d99947e371967a65e7d2f5d7729bc0ae23da5f5c788b54707007d094c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.264/agentshield_0.2.264_darwin_arm64.tar.gz"
      sha256 "d4a153e93d02dd81bb672ea3cba34edb6e09dc8d6153fd2fcf9ef81da37868e6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.264/agentshield_0.2.264_linux_amd64.tar.gz"
      sha256 "c87ef1dfca4fa0ad9382fb9194674eada64f7c79a1731a61f77201542bc3045f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.264/agentshield_0.2.264_linux_arm64.tar.gz"
      sha256 "ecd27c591a5f8b23af356c93c1f0016a346958ad6fe21de2d5180557d543977c"
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
