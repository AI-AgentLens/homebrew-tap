cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.607"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.607/agentshield_0.2.607_darwin_amd64.tar.gz"
      sha256 "89ff01b026190b0186e4c9f7c6a5ce0ef0d50dccc8cfb3dc885195c475c3675d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.607/agentshield_0.2.607_darwin_arm64.tar.gz"
      sha256 "7693d9478ddc434c34c293ad4d77125093871612e5f342b3e4a53a8c59e8b219"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.607/agentshield_0.2.607_linux_amd64.tar.gz"
      sha256 "585aada22bf02e483876dec46408b44566040046bbbe30808b81560a0d44bffe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.607/agentshield_0.2.607_linux_arm64.tar.gz"
      sha256 "bb11aecb389839960882ddd3714e2ccc518198e72f9036ea1e6d724805bfe173"
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
