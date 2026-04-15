cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.592"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.592/agentshield_0.2.592_darwin_amd64.tar.gz"
      sha256 "e40e3d85b034bbfabefd50d31d449f36186c693c5e49391cb0359ef1be21e2b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.592/agentshield_0.2.592_darwin_arm64.tar.gz"
      sha256 "fafae54e286aca5e86ff55a5468fb0a526fe0cbcffca2851590cdbf42b20c4c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.592/agentshield_0.2.592_linux_amd64.tar.gz"
      sha256 "e08f698add5d51305fbfe9eb87f43d4ad325230cd4938bb99fa0a2184b8e29de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.592/agentshield_0.2.592_linux_arm64.tar.gz"
      sha256 "0fb9474076f4d6c3fb9671732bb82b5694a2da5fb0adf04abed958af4430bd9a"
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
