cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2413"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2413/agentshield_0.2.2413_darwin_amd64.tar.gz"
      sha256 "f8a41fe803626868e992f9160837795478a16f149a5c01afa0387af0dfb8c9ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2413/agentshield_0.2.2413_darwin_arm64.tar.gz"
      sha256 "d449c29634b3e625d6884935855c0f590c4dcc390d57be18642408e694b7af7b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2413/agentshield_0.2.2413_linux_amd64.tar.gz"
      sha256 "2c392689a5bc60576f78a62fb5d24397bc7f133d013696d3515ee05928029203"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2413/agentshield_0.2.2413_linux_arm64.tar.gz"
      sha256 "cf78b666250ee1147134a2777e11d229d4dc17ae507727cfca15264cfd9c709e"
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
