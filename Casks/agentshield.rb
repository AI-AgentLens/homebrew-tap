cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.780"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.780/agentshield_0.2.780_darwin_amd64.tar.gz"
      sha256 "738ceb63f6fb46e678ea08393632162430fe58d489fde581f47050d40c4148ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.780/agentshield_0.2.780_darwin_arm64.tar.gz"
      sha256 "7c7dcbc0e26938db9e7dad0c345ffaf04b78d4e2bedb816e76b54e22f8fc6a78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.780/agentshield_0.2.780_linux_amd64.tar.gz"
      sha256 "ef41b8a984dda596cffdcd18b51cba9a5274db93a0bcc057987df1c41867fef5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.780/agentshield_0.2.780_linux_arm64.tar.gz"
      sha256 "8a3c3a3b946feb202227b429301948950373b9532af9a10eb7c766a078a789d9"
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
