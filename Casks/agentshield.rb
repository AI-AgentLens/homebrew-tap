cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2523"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2523/agentshield_0.2.2523_darwin_amd64.tar.gz"
      sha256 "a5a0c753e090666ab612d85d6345459c3a9ef7fd4105bbef1fc49814d5c7b549"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2523/agentshield_0.2.2523_darwin_arm64.tar.gz"
      sha256 "9acd82d9dde9c931e47f01ac6ebd2b2263534f30241e148d9be947ae69d5dc2a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2523/agentshield_0.2.2523_linux_amd64.tar.gz"
      sha256 "c6f76bf3f940b4d5c8cc91239a68d4de96efe583101380488da4d1299dfde246"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2523/agentshield_0.2.2523_linux_arm64.tar.gz"
      sha256 "577d165508535dcb5820a019563684555c392f8fef9a13e0bde3543b2ff55749"
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
