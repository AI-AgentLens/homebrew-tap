cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.177"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.177/agentshield_0.2.177_darwin_amd64.tar.gz"
      sha256 "bce6aeffba30d3787ef80fc283791af866905ac31c6ab9949b43adcae5f8122d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.177/agentshield_0.2.177_darwin_arm64.tar.gz"
      sha256 "6e7975e20ff4fa7863ae1d07c59560808bee147836aa7ce9ffaf18558d849e71"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.177/agentshield_0.2.177_linux_amd64.tar.gz"
      sha256 "1640e55905a563102d874ddf19d7f6b019b02a848a1602bcf23685a5768dc1a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.177/agentshield_0.2.177_linux_arm64.tar.gz"
      sha256 "a97e9f7c2d67c1a3b34e97ef10abb3438869fb942884dea5183c43e365ea0b12"
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
