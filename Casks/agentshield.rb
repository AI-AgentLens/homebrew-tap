cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2387"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2387/agentshield_0.2.2387_darwin_amd64.tar.gz"
      sha256 "c70d0dc43c97a9fca0dd260c8391273737aea6cf9d4277c44c49656ac376baa2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2387/agentshield_0.2.2387_darwin_arm64.tar.gz"
      sha256 "d89e8a9fbe5a09f55ae67729fcdff0121561c3618d2a27077ebbb935e3e05956"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2387/agentshield_0.2.2387_linux_amd64.tar.gz"
      sha256 "57624b0269aae8763437d5dfa09eeac63ebf08c1ef1bf8e7985e243d858b2ec0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2387/agentshield_0.2.2387_linux_arm64.tar.gz"
      sha256 "1f460d123ce3a046dbd3eae47112933594b4583d4b914a11533479b485c2223d"
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
