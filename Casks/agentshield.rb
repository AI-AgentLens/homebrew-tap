cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2138"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2138/agentshield_0.2.2138_darwin_amd64.tar.gz"
      sha256 "d1420268643bf308eee90189c7d85c1fce91397a2376741f2184bd2f0e98251b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2138/agentshield_0.2.2138_darwin_arm64.tar.gz"
      sha256 "6f2ef7954bb73b03b93a7353efb14b574dd95524822e55eb64e62b466977afa7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2138/agentshield_0.2.2138_linux_amd64.tar.gz"
      sha256 "cdd5e6031a1d339a2132bcfe5979f7ee7fd14859bd2744d1c3d9a40f119797b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2138/agentshield_0.2.2138_linux_arm64.tar.gz"
      sha256 "b89ce81c1a04074ee5cfc749abc2f50d794f1a5f53818a3fecd1a137fdadf179"
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
