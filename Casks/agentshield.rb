cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.736"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.736/agentshield_0.2.736_darwin_amd64.tar.gz"
      sha256 "b0d66ceb361a6e9640a45f987b61fffac763022856e3d2a953645d6bbcc72990"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.736/agentshield_0.2.736_darwin_arm64.tar.gz"
      sha256 "e429a1699e9b01876c857f0abefbbb9586babc0f9f3934bba4fde554f7157d7c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.736/agentshield_0.2.736_linux_amd64.tar.gz"
      sha256 "4885f7b10a42351d9ee26737e1623d4203c5cfee8d7583192db1ddafc329171e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.736/agentshield_0.2.736_linux_arm64.tar.gz"
      sha256 "b6056654925e942f5124f822ae2a8095c3cf3ace097c215c02da88d25985d591"
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
