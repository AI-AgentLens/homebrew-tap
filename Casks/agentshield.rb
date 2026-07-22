cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1707"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1707/agentshield_0.2.1707_darwin_amd64.tar.gz"
      sha256 "753f05e7c4a58e26586ca78c883694892b47ff21d080e27139b9ddaa7581bcba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1707/agentshield_0.2.1707_darwin_arm64.tar.gz"
      sha256 "2d30ac8ea816d95e4528b099dfe066fe830610f599e75978bbc988e5cc31d20b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1707/agentshield_0.2.1707_linux_amd64.tar.gz"
      sha256 "2afbd26743f063b93997a1c899b6e0298b82f4739443cbc566a83f818f8dcb4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1707/agentshield_0.2.1707_linux_arm64.tar.gz"
      sha256 "f1e2c6dfaf1a04dbe92d3c1b06c2ca7a6fc272cb15faeb03a4af7706d3415a4c"
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
