cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.458"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.458/agentshield_0.2.458_darwin_amd64.tar.gz"
      sha256 "f1ad8beaa7c825a558fbbe7d9b715b235ad8dcea595e831ee70556717cb1469f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.458/agentshield_0.2.458_darwin_arm64.tar.gz"
      sha256 "93494bda8b9a5db4966c75b21348f1ca677b287b5ba04276857b52b39d877cf2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.458/agentshield_0.2.458_linux_amd64.tar.gz"
      sha256 "3889d3a33443195b848f1b9d9a81df6fd71ef64aa867655dc4cbe0b729f3ea74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.458/agentshield_0.2.458_linux_arm64.tar.gz"
      sha256 "367e05715bd10b94ab2439245f93fe1b7c5a2ea6f9b222fdcd99def2471ce4c9"
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
