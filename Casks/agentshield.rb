cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.872"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.872/agentshield_0.2.872_darwin_amd64.tar.gz"
      sha256 "50c8873fa43c0d0269290398c7085d559403ae7b675c7a94e39e8ea0f290b428"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.872/agentshield_0.2.872_darwin_arm64.tar.gz"
      sha256 "6d9a5211b7b49aeca667c2c91f5b6fca281b45ba0ffebb27e58fe9b40561e421"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.872/agentshield_0.2.872_linux_amd64.tar.gz"
      sha256 "7333b1026998b73e4762a7fe26aaa41e8ba0cba35076fec4df0735a06a670e64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.872/agentshield_0.2.872_linux_arm64.tar.gz"
      sha256 "a89099037abad18c0c498cf2e025b42ecfd29b7291fa42d1ae7d1cc9f286732c"
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
