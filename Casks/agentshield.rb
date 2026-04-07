cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.454"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.454/agentshield_0.2.454_darwin_amd64.tar.gz"
      sha256 "6b5c570e595f381748d0493ee4b53b09e92bdc6bd9c0afa7109aad62fcb08dbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.454/agentshield_0.2.454_darwin_arm64.tar.gz"
      sha256 "76b1179d2e043232324a95f516e770124fcf15c1b1b3512e409186188c3b8959"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.454/agentshield_0.2.454_linux_amd64.tar.gz"
      sha256 "068d97bca75c3fe1f478593a8e338c5047c556ee3c4ce019fc524cd416ac282f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.454/agentshield_0.2.454_linux_arm64.tar.gz"
      sha256 "6e57f5aa134afcb9c445d986f1b3b2d16d57cb9351490806abe86ac908ccf2d4"
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
