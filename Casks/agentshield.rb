cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.871"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.871/agentshield_0.2.871_darwin_amd64.tar.gz"
      sha256 "b15b8b2a6f9e2e967649ad5e3d22fc4cc26f4cb61a1ffdbbe366f88f77157224"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.871/agentshield_0.2.871_darwin_arm64.tar.gz"
      sha256 "95d1b1e03802de7c89e40442021dd6e0df01c0038754de830521cee2e0701649"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.871/agentshield_0.2.871_linux_amd64.tar.gz"
      sha256 "465d4e05cb81e4d10144b33b183273129fc2c8188a9ce8aec05a766b0e75c013"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.871/agentshield_0.2.871_linux_arm64.tar.gz"
      sha256 "31fcf01c822eea1623137441e07713b06192424843f88c78abfe5343bf0e28a1"
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
