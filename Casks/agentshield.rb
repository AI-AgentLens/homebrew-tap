cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1559"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1559/agentshield_0.2.1559_darwin_amd64.tar.gz"
      sha256 "47234198a3547c119a631e3a2a53c0583b26ba28e63a23c35eb379dc36b1af29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1559/agentshield_0.2.1559_darwin_arm64.tar.gz"
      sha256 "855de9e8d42eeaa2f638763184824aae7c6a317b61ec40937e9fd33e9fc63ac2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1559/agentshield_0.2.1559_linux_amd64.tar.gz"
      sha256 "11b42d0044946e1507cc7c43c68c5881792e34d149e762de69b1e473cdb3bd79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1559/agentshield_0.2.1559_linux_arm64.tar.gz"
      sha256 "027faf316023d178fb4146035df94903f7939589902ca22d39cb711c09ab417d"
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
