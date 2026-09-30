cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2298"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2298/agentshield_0.2.2298_darwin_amd64.tar.gz"
      sha256 "36181949b4769b2cfc8b80a127a157a9286230af131794778d1d852281c6e213"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2298/agentshield_0.2.2298_darwin_arm64.tar.gz"
      sha256 "63d2e74bd6105053ef68ee62f04c7efdfc0022afa20c8b9253312afed3974062"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2298/agentshield_0.2.2298_linux_amd64.tar.gz"
      sha256 "84427c5d50dc283a6b673c80bd46e0ebe20128d28c1114f2a77fff031194f759"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2298/agentshield_0.2.2298_linux_arm64.tar.gz"
      sha256 "aac3330560332c04c9fb71ce7512ac923ab52779fc0ace3db7149b3306e06fa7"
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
