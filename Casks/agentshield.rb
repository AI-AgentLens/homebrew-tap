cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1080"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1080/agentshield_0.2.1080_darwin_amd64.tar.gz"
      sha256 "c205b90ab8363434b8e19588ff4d5094fa8684fda34fcdb1194d73f5ceb7b443"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1080/agentshield_0.2.1080_darwin_arm64.tar.gz"
      sha256 "5ca8e5a36f0fcffb5115cc5d5c89161d33251bbbecd7143f93cdfbc8c7d1952e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1080/agentshield_0.2.1080_linux_amd64.tar.gz"
      sha256 "b6f4afffa87db22453bb55efb5f14f29e3c0a3633c681d76f52c19331152d816"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1080/agentshield_0.2.1080_linux_arm64.tar.gz"
      sha256 "1b8190dd96b84d08b1a05c41b5fc46b32016ada62b49e6623e196a77babbdada"
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
