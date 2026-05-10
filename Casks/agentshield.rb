cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.941"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.941/agentshield_0.2.941_darwin_amd64.tar.gz"
      sha256 "bc3f128f974e94693f44ec59745272468a7fde88bceff00cc6b8359d0cd97c9f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.941/agentshield_0.2.941_darwin_arm64.tar.gz"
      sha256 "905dd6c54494aa0f152d21158c22e039852cd8a9540ff636de155f0e954cfc3c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.941/agentshield_0.2.941_linux_amd64.tar.gz"
      sha256 "833dd7c25f4ebb18bd45d5d5227311d9fd017746ec308d5f7a4c4f4b96ace161"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.941/agentshield_0.2.941_linux_arm64.tar.gz"
      sha256 "92fce69063815139dd48e2e9145cd35a61a85a702d8f3d079d49304a58871da2"
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
