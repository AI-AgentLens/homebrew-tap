cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.883"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.883/agentshield_0.2.883_darwin_amd64.tar.gz"
      sha256 "e2418cf21a3fc2f34e08d434067545542b1fd60e703d21b1329343874e771196"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.883/agentshield_0.2.883_darwin_arm64.tar.gz"
      sha256 "8928194d11db304dd9b5d8b5470d836c82e9a864567686a1e7e8a1d517e3c82b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.883/agentshield_0.2.883_linux_amd64.tar.gz"
      sha256 "e5b9ad9b5010c0d19877df4ea742c95e88ba9bac5f9d27d0a3db63bb087737a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.883/agentshield_0.2.883_linux_arm64.tar.gz"
      sha256 "8093aff407031968f652b3b956e4d214593adc3155e7daebd6f6a6a531740932"
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
