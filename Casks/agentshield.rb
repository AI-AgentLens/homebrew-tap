cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1292"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1292/agentshield_0.2.1292_darwin_amd64.tar.gz"
      sha256 "80679d1c6df4406d0fd3505d5900814094a67e8d79021add9dbd4f12d88c08ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1292/agentshield_0.2.1292_darwin_arm64.tar.gz"
      sha256 "806399bd7b2b7b86fa4177081758a473b8afac6aebe6d78f11d4bc3a7b054560"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1292/agentshield_0.2.1292_linux_amd64.tar.gz"
      sha256 "756267303c3c0b91b2c83342633e8f18320a046c7700b449868876a08fbc63b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1292/agentshield_0.2.1292_linux_arm64.tar.gz"
      sha256 "20b0a7759ccb6f0497ff32a5eff58b870ce41094bbb0502e1259098a2f00dddc"
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
