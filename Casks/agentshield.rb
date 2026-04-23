cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.703"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.703/agentshield_0.2.703_darwin_amd64.tar.gz"
      sha256 "ecc8438398123b365dd51214d51e31d7c49a195a35fea4441e3cbf85c0756fca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.703/agentshield_0.2.703_darwin_arm64.tar.gz"
      sha256 "8b48904758b38324e4aa1e33f122869ed65934b650eb04a59a461218f14b94ab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.703/agentshield_0.2.703_linux_amd64.tar.gz"
      sha256 "dcc889a082183f14cf0589bb4173b79402e37957dd4e4618f695ffc68ada101a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.703/agentshield_0.2.703_linux_arm64.tar.gz"
      sha256 "4e087e78ed262879d949a625ee4df7882fdad67c70061ce02331b4a9ee62654a"
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
