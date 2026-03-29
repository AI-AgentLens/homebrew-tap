cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.204"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.204/agentshield_0.2.204_darwin_amd64.tar.gz"
      sha256 "86d65edc3f5d9f8764d68a8b2fcf5fe64d1f1b6765a66ece85aa32703915120d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.204/agentshield_0.2.204_darwin_arm64.tar.gz"
      sha256 "6c7e5ad0122e5f3bed1c047939719d3a67763922b3640391cdaeb729001b561a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.204/agentshield_0.2.204_linux_amd64.tar.gz"
      sha256 "c89876ff5ebaf867c75b0daa105f6883aaf4e4a8d54654459aa1d902a4235f85"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.204/agentshield_0.2.204_linux_arm64.tar.gz"
      sha256 "6b1429dd36e5b5af265ae1090667d7de9ffd5a31ee2c6c9cf61decdda2ba4e33"
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
