cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.903"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.903/agentshield_0.2.903_darwin_amd64.tar.gz"
      sha256 "3378f2361c8acf3ea6b7f4e3e13e55507824363ca5c4baaa19040a2f6c77af8a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.903/agentshield_0.2.903_darwin_arm64.tar.gz"
      sha256 "22d19df0a49f7993a58c648d34997c16ffa5ef3a9f26f1ba220a6fe5ea84b1b6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.903/agentshield_0.2.903_linux_amd64.tar.gz"
      sha256 "c87e68b70b08f21b5da4c18745a32b8ac58e1ee3417dfe0efaf325217e94842f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.903/agentshield_0.2.903_linux_arm64.tar.gz"
      sha256 "9f9cf27b4a80a447482277d83646f17d33abd9e231fb88e63b2b874fe42a0a8a"
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
