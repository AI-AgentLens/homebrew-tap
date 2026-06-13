cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1306"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1306/agentshield_0.2.1306_darwin_amd64.tar.gz"
      sha256 "d7c13f3e53c272d8a78d73668b2d586c7ed2d1e0cf229cdb2054d85283a3ffd0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1306/agentshield_0.2.1306_darwin_arm64.tar.gz"
      sha256 "df75373dcb432d6fc749118af766785c2930553d48eff298e5ce857ff5b033e3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1306/agentshield_0.2.1306_linux_amd64.tar.gz"
      sha256 "f49e526b7f7e187e1acfeeb8427fc94e1957686c6b286049bd486b674792ca37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1306/agentshield_0.2.1306_linux_arm64.tar.gz"
      sha256 "baddc08a29225b5e938361d9a793c33db609287c1bb25820e1e4cd29d52839fa"
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
