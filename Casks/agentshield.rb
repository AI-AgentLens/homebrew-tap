cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.288"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.288/agentshield_0.2.288_darwin_amd64.tar.gz"
      sha256 "5d9ae44f5cefcc1a602412646c1b76a8d26711a364041c8224a0e56f7568edf7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.288/agentshield_0.2.288_darwin_arm64.tar.gz"
      sha256 "a3af11cbe2b8d0ed75bc5a9142113271a3f279af6b9688be0f0aa4095884f01f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.288/agentshield_0.2.288_linux_amd64.tar.gz"
      sha256 "391d96adb2e2358674aa68db774382650ba598be2a6c0978c97c6dacb6517d5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.288/agentshield_0.2.288_linux_arm64.tar.gz"
      sha256 "06573a1f0ebc2902bab30b46bc149b2e189e03e5d428c5ae6e5f14333d96dd30"
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
