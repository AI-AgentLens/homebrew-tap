cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.503"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.503/agentshield_0.2.503_darwin_amd64.tar.gz"
      sha256 "146a10cbe78e8e6597169020bdbfe95a762ee141729132863675c7d98d5b7ee4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.503/agentshield_0.2.503_darwin_arm64.tar.gz"
      sha256 "226eda8d5fcc57133e6b4c6f11ba41865703fd0fed5221c62c86cc9c91075e81"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.503/agentshield_0.2.503_linux_amd64.tar.gz"
      sha256 "a83a3e2466209bef309580fbd5b8757920ffe169eaa3eef7403ecabf7aae09db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.503/agentshield_0.2.503_linux_arm64.tar.gz"
      sha256 "7495da0878ebd2f94d1b3941b50ede099a7837f3b1893de2d5e77ef6414f373f"
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
