cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.445"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.445/agentshield_0.2.445_darwin_amd64.tar.gz"
      sha256 "df068740c8282934c6b67d35f3fedf1da03dc34febcc2de69698739f068dac36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.445/agentshield_0.2.445_darwin_arm64.tar.gz"
      sha256 "481360dcdefcb71df086bf1099b9ea9343b5d24ea64cdc9ecb90f771ae9e4799"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.445/agentshield_0.2.445_linux_amd64.tar.gz"
      sha256 "973a3a5e5acdf28ea52e57a0cbbbd537a766592dac12ec81fbe74afeb49ba9cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.445/agentshield_0.2.445_linux_arm64.tar.gz"
      sha256 "0d66063e9957b1cd0375064bbd92931a363153d506e1f10bde55ada34ee5b066"
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
