cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1567"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1567/agentshield_0.2.1567_darwin_amd64.tar.gz"
      sha256 "a2cca938bf9d0ba2e564def5ebdabaa143c08f35e6da5a61095a836801fe2ec1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1567/agentshield_0.2.1567_darwin_arm64.tar.gz"
      sha256 "e75a61e9b67ba25d7bbe93983cb8f2e900cca97cbbd4c806b43c5da9c3fb766d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1567/agentshield_0.2.1567_linux_amd64.tar.gz"
      sha256 "aebe2e901322944b8c1279e948ed31eda0627054afb17b42187456873b4d1b57"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1567/agentshield_0.2.1567_linux_arm64.tar.gz"
      sha256 "47bf199c29479faf88d6328aec8e8c648398d373147806791f1837df65b67539"
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
