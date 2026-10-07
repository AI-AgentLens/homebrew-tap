cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2379"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2379/agentshield_0.2.2379_darwin_amd64.tar.gz"
      sha256 "98e5a8cab0dc4872446c93988706278b4abbd5d88de778b89c98e1764b6fe850"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2379/agentshield_0.2.2379_darwin_arm64.tar.gz"
      sha256 "e9d012fc67a3f9504ba0d971096378b464e1b5ae24c80c289cdb6f3aebbe9065"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2379/agentshield_0.2.2379_linux_amd64.tar.gz"
      sha256 "5c68946b503d18c6bb9fe64b4c0642a8ded6630f12b5e3d57ce2a25700e5d614"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2379/agentshield_0.2.2379_linux_arm64.tar.gz"
      sha256 "be558494ff2c5c28f29dfa88eaa54596da61dd7d924f21571fc545882cef113c"
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
