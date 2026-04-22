cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.678"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.678/agentshield_0.2.678_darwin_amd64.tar.gz"
      sha256 "4f186d9a37308f5399b1f6252114397a28d0b30cec043d707a59e86dd18fcd0e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.678/agentshield_0.2.678_darwin_arm64.tar.gz"
      sha256 "6e8df3653143594f551c7517c1260ebb9f4c41f6e0e471881e94f7f4ea3cb009"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.678/agentshield_0.2.678_linux_amd64.tar.gz"
      sha256 "7e65a0366733ea33c2e6b04ab780786453a7b3723d93453fbf8ebe432ab7cd77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.678/agentshield_0.2.678_linux_arm64.tar.gz"
      sha256 "7760d9c0ade59a837fbc4ecde95b6df43387099fe17ff3da7d804c16a15b6284"
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
