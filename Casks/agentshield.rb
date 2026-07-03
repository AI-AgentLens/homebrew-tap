cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1542"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1542/agentshield_0.2.1542_darwin_amd64.tar.gz"
      sha256 "0ea8826fcdc009b6b337a2c9341ea2ca2a0bda149bc1c9e6f32260bf406866a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1542/agentshield_0.2.1542_darwin_arm64.tar.gz"
      sha256 "fca92dee2bde297b84e412ae41bdfb0079969e6b9be902f806888f59e0d913df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1542/agentshield_0.2.1542_linux_amd64.tar.gz"
      sha256 "8908f7b98c4b7638ff549b9f5d452d3d4f4513251c2069133773a895c061e649"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1542/agentshield_0.2.1542_linux_arm64.tar.gz"
      sha256 "558476f5c7c9acc70a6f777ea4c6dd29d099c22496e5e63b93b9e13389029512"
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
