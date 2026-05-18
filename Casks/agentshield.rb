cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1024"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1024/agentshield_0.2.1024_darwin_amd64.tar.gz"
      sha256 "22d080b4bd51bbbca8aaf55bc3cb7bf81199d85fa90b7cf0cefc7e3cc04d0f7b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1024/agentshield_0.2.1024_darwin_arm64.tar.gz"
      sha256 "a9ace31703fb9bb6ab66c82f2b9474adb3b294fac98baea2fc3078fd30443201"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1024/agentshield_0.2.1024_linux_amd64.tar.gz"
      sha256 "cd985e2b9db747ff63f9216d75b14f29799f82cb97422277f9a62131b8fddf05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1024/agentshield_0.2.1024_linux_arm64.tar.gz"
      sha256 "16ca3fac566a3ba8543cfb65017ef2793d8055075b0cda630f9b06e2e026dcc9"
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
