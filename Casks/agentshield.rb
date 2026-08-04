cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1786"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1786/agentshield_0.2.1786_darwin_amd64.tar.gz"
      sha256 "f6c2b26fcf8710274c671a5a709802fb42131b443f195e9fadae6cc5bb9b9249"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1786/agentshield_0.2.1786_darwin_arm64.tar.gz"
      sha256 "f7fb4b0e7f3802e5d4bf08334bf76501df29b320cf744afa9d2b61834d92ee1d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1786/agentshield_0.2.1786_linux_amd64.tar.gz"
      sha256 "6c987c795ca06885e2959f007f1daf1acea8d983fbc185dd4c14057114b352cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1786/agentshield_0.2.1786_linux_arm64.tar.gz"
      sha256 "72725c9a0dc9f91e271dd0255a5caea514f5539ae3de7ec12e0ebad018f1ff23"
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
