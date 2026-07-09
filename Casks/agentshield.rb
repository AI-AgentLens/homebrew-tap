cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1600"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1600/agentshield_0.2.1600_darwin_amd64.tar.gz"
      sha256 "076b7d542d911856d1695a9f25c46c2a87703e768dcc504789b7b429e1709120"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1600/agentshield_0.2.1600_darwin_arm64.tar.gz"
      sha256 "87322e581e776afedd66f0253f884fa84945653ac29f91de4d1286fbb5c29731"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1600/agentshield_0.2.1600_linux_amd64.tar.gz"
      sha256 "c84daeab5f3f8c491bbd2843d54c198c26ad7409166029e3b0bbd932ca2cc299"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1600/agentshield_0.2.1600_linux_arm64.tar.gz"
      sha256 "dbcc2a38c4f4c5fe02f3edb9252d30db86747a0abf8d23ac63606339e7c54c47"
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
