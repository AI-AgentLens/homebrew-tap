cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.991"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.991/agentshield_0.2.991_darwin_amd64.tar.gz"
      sha256 "0f3dd79e31e201466eb3bd002f6ae5458941f49768bef607e955f46f0e798e7e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.991/agentshield_0.2.991_darwin_arm64.tar.gz"
      sha256 "122cda001a393a289f76a54651bf1a63a7849693a1d08a9a0a5ff57f348fb930"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.991/agentshield_0.2.991_linux_amd64.tar.gz"
      sha256 "949660f7acc002abc14d20c29ec78f2a8b770db601e97f5f4bc32761954b1e96"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.991/agentshield_0.2.991_linux_arm64.tar.gz"
      sha256 "f13bc540b3151043eef0f8c49c307efaa4a7aa99eaff2c76ae9b403aa04d4cdb"
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
