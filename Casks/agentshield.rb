cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1360"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1360/agentshield_0.2.1360_darwin_amd64.tar.gz"
      sha256 "3e3d1b7ac10328ae9561e06eb63ca6b55b51e2bf82718916371ed9faa0553f57"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1360/agentshield_0.2.1360_darwin_arm64.tar.gz"
      sha256 "2f4e095ab83e9e463bc8b2b14f7d070fe85c245ff9ed4ca2bf3967e0a299d82d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1360/agentshield_0.2.1360_linux_amd64.tar.gz"
      sha256 "d8b7d96acb318b9d36d58e6ebf15c77d582eae955994eb8fd5a93ebb3652d830"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1360/agentshield_0.2.1360_linux_arm64.tar.gz"
      sha256 "92c9773e3b2772a8542ec85958db7421bff276393224eaebe93cf4d5de042d63"
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
