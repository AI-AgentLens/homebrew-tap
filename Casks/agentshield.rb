cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1435"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1435/agentshield_0.2.1435_darwin_amd64.tar.gz"
      sha256 "ab1254a07a6059f21629b8249146e1e6ed9cdd6c8b64fbbd1c925f9ac3d2c0d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1435/agentshield_0.2.1435_darwin_arm64.tar.gz"
      sha256 "1b6ace79a30b4954e56b2062d97fbf9e4a03aaf6d379e3dade2d407deddcef31"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1435/agentshield_0.2.1435_linux_amd64.tar.gz"
      sha256 "191d5c4b1ae352f8d9c8d661fabbf3f30de444b2ac0eb4b736a141e2a22fc876"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1435/agentshield_0.2.1435_linux_arm64.tar.gz"
      sha256 "49a98821a17e789768f1c981db85110f20694898ffef60ddbcc79acaad474ae7"
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
