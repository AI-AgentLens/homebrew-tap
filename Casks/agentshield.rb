cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2406"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2406/agentshield_0.2.2406_darwin_amd64.tar.gz"
      sha256 "d20a9c958f9ca3412b067c352bfd6732a6eb493dc964fd658753308d2060dadc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2406/agentshield_0.2.2406_darwin_arm64.tar.gz"
      sha256 "d4ffcba08eb36507ea350ea78408d10406e40359607fbb207fa85cf39b3fb061"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2406/agentshield_0.2.2406_linux_amd64.tar.gz"
      sha256 "a136ec72a3ff8b45ca4685a0db2cb88dbbd4cb4371900af257ff56af2790063b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2406/agentshield_0.2.2406_linux_arm64.tar.gz"
      sha256 "ae11f6db088157ca5517d06e28366113215e12e22f83ae98bdad491228d27511"
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
