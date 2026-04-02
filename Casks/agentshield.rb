cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.290"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.290/agentshield_0.2.290_darwin_amd64.tar.gz"
      sha256 "5c461c244ca2b9614f9473c7a438cb4b8777101f7bda5177832cb2c39ab4793d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.290/agentshield_0.2.290_darwin_arm64.tar.gz"
      sha256 "84c314937c0d0b2251c7bf33651a483c67bdf6fedd5c0729ab239762884eef0f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.290/agentshield_0.2.290_linux_amd64.tar.gz"
      sha256 "73bdb59351f7d005144627201b498ef6f7737da997d5d0032f5d72caa03fe157"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.290/agentshield_0.2.290_linux_arm64.tar.gz"
      sha256 "d8d24853676c8e2edba22096a2ab8f805811ccab88ea5beff489b8000738f9b7"
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
