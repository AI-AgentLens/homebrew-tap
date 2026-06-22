cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1409"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1409/agentshield_0.2.1409_darwin_amd64.tar.gz"
      sha256 "6c1575c643fcd28990303fef88d89c68de8425a514852e2135222eb73c1d88a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1409/agentshield_0.2.1409_darwin_arm64.tar.gz"
      sha256 "535894f6cd6689928e29c565576dff8348a66c2f0fcd8e5efae685e095434237"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1409/agentshield_0.2.1409_linux_amd64.tar.gz"
      sha256 "33bd967ed9447ea1350dccb95c2b3008df27a6c5ec6281d20e5251f346e8d6fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1409/agentshield_0.2.1409_linux_arm64.tar.gz"
      sha256 "a98d620edfd1a17763436e95be2ee31584edb22cfe70a912dd7e53554b71b0e0"
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
