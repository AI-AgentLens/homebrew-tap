cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.907"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.907/agentshield_0.2.907_darwin_amd64.tar.gz"
      sha256 "c49c9fe8ca5e3a03108b8060b114dbc1b99e2bbdc8bbbb5678b3fa8982d0761b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.907/agentshield_0.2.907_darwin_arm64.tar.gz"
      sha256 "1e100d8d708ea5f512e3d3422bceaed8546e4c820383c9fa16ae5c0b35fa2fc0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.907/agentshield_0.2.907_linux_amd64.tar.gz"
      sha256 "4408d556f1f1f0214548607f7a904374f1da23e2c9d7c899c451057f83074e1f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.907/agentshield_0.2.907_linux_arm64.tar.gz"
      sha256 "b06f76c53fcf372b3fc2f847651abf6dc681bdd8a97e181ba583f046f42c6465"
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
