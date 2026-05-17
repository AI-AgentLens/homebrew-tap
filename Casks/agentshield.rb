cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1006"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1006/agentshield_0.2.1006_darwin_amd64.tar.gz"
      sha256 "24364409643d3f216174de7b7c3f1a0a39d9464eb07905eef83494065050fdfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1006/agentshield_0.2.1006_darwin_arm64.tar.gz"
      sha256 "b70ccbf8516847af418dd43625be8d2611cd5af11c8cf5f56c8f0c65f04dc7a7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1006/agentshield_0.2.1006_linux_amd64.tar.gz"
      sha256 "795f2544564f97b63bec788e498e02d90b332aa9a2eba15175b8b942fe1c1194"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1006/agentshield_0.2.1006_linux_arm64.tar.gz"
      sha256 "73bf47b6fea9a3b3b90fbd2ee7e5fe89fe39262b34b32ba3d5f528cd00b05de4"
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
