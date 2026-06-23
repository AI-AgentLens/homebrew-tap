cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1414"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1414/agentshield_0.2.1414_darwin_amd64.tar.gz"
      sha256 "10a67d895c3441e9990e4ebb61807aa08beb14e797635594ed498f3868620f3f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1414/agentshield_0.2.1414_darwin_arm64.tar.gz"
      sha256 "5a4fc18cd1d55b612c7aece058ca31502f97c1217584233242fcfd849da1759f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1414/agentshield_0.2.1414_linux_amd64.tar.gz"
      sha256 "4c5ed3049f4dd0c0aa766d57a4f9713aeed6b4949e92a14764d955be568da7d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1414/agentshield_0.2.1414_linux_arm64.tar.gz"
      sha256 "58f107c0b74c08d3e167c27b416f4272ebb62d58111cb43870a3411f56fee78b"
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
