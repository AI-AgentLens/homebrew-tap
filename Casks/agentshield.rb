cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1266"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1266/agentshield_0.2.1266_darwin_amd64.tar.gz"
      sha256 "b74ae4ef235abe88ae315ccc552ec8113452ba221b39f1b585a3e4bc343cac76"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1266/agentshield_0.2.1266_darwin_arm64.tar.gz"
      sha256 "14fdc17bb2bfa17d5675bf4d8a24d275cfb3983d6dbf8ea9455402d721d5488d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1266/agentshield_0.2.1266_linux_amd64.tar.gz"
      sha256 "1daa32264564b538d266dc089f6ccf449ca7665b41973d9dbc5b3af7bb8cd9a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1266/agentshield_0.2.1266_linux_arm64.tar.gz"
      sha256 "8b5de5c266b477f9d58010e07f762880b987754f16cb8e66d1e43af88a94bb84"
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
