cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.691"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.691/agentshield_0.2.691_darwin_amd64.tar.gz"
      sha256 "d3a1e5a89a066707fb355261c781ee200b39194e9cfa10972a57ba3bcd07d080"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.691/agentshield_0.2.691_darwin_arm64.tar.gz"
      sha256 "53bcb46ba1dcf5c630e96616610dfe877ee868615407da3d4d8fa9b187547323"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.691/agentshield_0.2.691_linux_amd64.tar.gz"
      sha256 "a4f7ef56b76a8f2b1bd3f3d6f5075d6159f5c64b147f68045e51eff9df5c90ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.691/agentshield_0.2.691_linux_arm64.tar.gz"
      sha256 "dfc46e53ac554112ddcd7110bbc320921d4a57526ed03ed0fc4b00d8a1d5c44e"
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
