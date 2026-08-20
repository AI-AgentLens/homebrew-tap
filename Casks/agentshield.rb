cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1909"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1909/agentshield_0.2.1909_darwin_amd64.tar.gz"
      sha256 "49fbe2116d96bada144598e71927c68d777f9d36fc2f3b59b712b699cb9af17a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1909/agentshield_0.2.1909_darwin_arm64.tar.gz"
      sha256 "e41ab40710a476ad61b2b2a57bbfc16b292d5d73922ef7fc888faea9bcdc60cc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1909/agentshield_0.2.1909_linux_amd64.tar.gz"
      sha256 "659eff4dced965ff0a03ddbbe7f54e9d2813d4971e62303a75f3c4f66bc36e87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1909/agentshield_0.2.1909_linux_arm64.tar.gz"
      sha256 "d8201ba928f5bd453b2d1c0ba5265a1b2ab3afa80597e8494248799c9d69e7a9"
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
