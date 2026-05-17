cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1014"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1014/agentshield_0.2.1014_darwin_amd64.tar.gz"
      sha256 "847b2d55c84b1f0b65e7b4824fb547030f7ba5bc56217e7079a5316d2506e78a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1014/agentshield_0.2.1014_darwin_arm64.tar.gz"
      sha256 "c660e8896b646662043a3a6a1e540e267d5da528fcfc997be1c595f6e2285898"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1014/agentshield_0.2.1014_linux_amd64.tar.gz"
      sha256 "79408ec3fe482af9c1b651dc41c7a3aaf68183b00d54b37e63673f4ab95f031c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1014/agentshield_0.2.1014_linux_arm64.tar.gz"
      sha256 "09f7e93a1d033c4e35274a3594060b121132da83054895253042a56007186d10"
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
