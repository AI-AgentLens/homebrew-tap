cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.156"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.156/agentshield_0.2.156_darwin_amd64.tar.gz"
      sha256 "72bd551b21999b46d978bbc11da0a9a65176c4ee9cda0c73fb24ba6a251d8f22"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.156/agentshield_0.2.156_darwin_arm64.tar.gz"
      sha256 "2aaf95bc855a27a4a85051b83f01b621a58cf2b52f4d1b2a6dc5bc76c6ec0209"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.156/agentshield_0.2.156_linux_amd64.tar.gz"
      sha256 "a05e38f4d0d463b04fb2e2e9d36fade2543a424ce1461498596b67c1edf7475b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.156/agentshield_0.2.156_linux_arm64.tar.gz"
      sha256 "a59e12451292e8b311aca8d2dcc53cdc8fe90d26ca8186817a0452cef5a9385e"
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
