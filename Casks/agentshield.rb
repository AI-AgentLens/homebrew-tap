cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1839"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1839/agentshield_0.2.1839_darwin_amd64.tar.gz"
      sha256 "881aa513cc55b3ee924b528ed68b73a6cd4cb805dd4b114650275856dc94a96b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1839/agentshield_0.2.1839_darwin_arm64.tar.gz"
      sha256 "7766d8ac3e44f5db19458ce02b5306d209c30684e9b9501bc00fff45c6e91ea6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1839/agentshield_0.2.1839_linux_amd64.tar.gz"
      sha256 "076a3f970c672d60397f1c2a372e6e535ea84bcc6ddb24ab929ba9089c2d09e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1839/agentshield_0.2.1839_linux_arm64.tar.gz"
      sha256 "3e1efb6686c7bec104246a76466973afd60c975ccee129b28aba61a14f060711"
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
