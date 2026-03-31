cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.273"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.273/agentshield_0.2.273_darwin_amd64.tar.gz"
      sha256 "aa5dd7ea0e9d4561e158116dd3e5e42d87399509127b55da9cf9aa565c07e1d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.273/agentshield_0.2.273_darwin_arm64.tar.gz"
      sha256 "08931238514c1f817afd0ff3dd1336fcb53523271174b7be5cb3bf23d5934780"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.273/agentshield_0.2.273_linux_amd64.tar.gz"
      sha256 "28a0871e3f9882e1bcc5070b57057d779a41110ea5847c6e5bec2082da0d6e64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.273/agentshield_0.2.273_linux_arm64.tar.gz"
      sha256 "b7768a323a7ef269b315299738c79d9cecbbb5356c6bd3ce57c42744e629f0ec"
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
