cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1001"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1001/agentshield_0.2.1001_darwin_amd64.tar.gz"
      sha256 "de030b7ad1121dbc1e1f53550c9f931e3e02616d6c0b694d0cdff71bfcf721e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1001/agentshield_0.2.1001_darwin_arm64.tar.gz"
      sha256 "3d7141966bccb7fd1e16ea35f04e9ea37054a79498ca3d88d8e1e49e189e3cd1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1001/agentshield_0.2.1001_linux_amd64.tar.gz"
      sha256 "d1d392b3eec68ec4eb2c367aab5ae4b625fb3656645f49f04d87f3490a068a85"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1001/agentshield_0.2.1001_linux_arm64.tar.gz"
      sha256 "682e0620061f36503a2947eeec0bd951ef981106c600f888c9c37d8fa5cf3fc3"
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
