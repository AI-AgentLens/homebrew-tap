cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1635"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1635/agentshield_0.2.1635_darwin_amd64.tar.gz"
      sha256 "57efc406ddb471cfd8e031b9c76a00127da04d3fe0a9d206c8d69f846ab5a4e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1635/agentshield_0.2.1635_darwin_arm64.tar.gz"
      sha256 "27a2835d03990cfd4d6fdf8cb56b10c47bacc657bdf256b65638b2fd0d4e8319"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1635/agentshield_0.2.1635_linux_amd64.tar.gz"
      sha256 "827e24f4e6a12f242567d014313493b7f288de6529f39212beba413a59a66f2d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1635/agentshield_0.2.1635_linux_arm64.tar.gz"
      sha256 "ca3ce204c1191adc4acead94c64971aecc8801d1a609acf7cfb9e1de0505b83e"
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
