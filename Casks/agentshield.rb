cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1604"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1604/agentshield_0.2.1604_darwin_amd64.tar.gz"
      sha256 "003501d5967b359602fa4e82c80b7b44f3e2d86fb90cc5500968bd468cbc9d83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1604/agentshield_0.2.1604_darwin_arm64.tar.gz"
      sha256 "3743e58ccb181408bd87b3493a16f341552e903257c337f223ebf502d25330e7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1604/agentshield_0.2.1604_linux_amd64.tar.gz"
      sha256 "1e33743e165e8b57535f8f872ad6b610198443771aa8e0285120183466ea7bd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1604/agentshield_0.2.1604_linux_arm64.tar.gz"
      sha256 "3951698c07c7ef601bd26c4051d60b99d8ec940b24599259251f058a82d1d269"
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
