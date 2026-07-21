cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1703"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1703/agentshield_0.2.1703_darwin_amd64.tar.gz"
      sha256 "da459aa9c3089a02007a56f604ccd6c416401285874469899fae61e839ebd978"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1703/agentshield_0.2.1703_darwin_arm64.tar.gz"
      sha256 "0fb78c96c213e0186eba39d691150e234ce6c8edab105d9ed33515dc08b0477c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1703/agentshield_0.2.1703_linux_amd64.tar.gz"
      sha256 "7efc13f38b5d00d6f1f005bb8c5911fb5afe04607b43a7dada4ec0bb8f1953c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1703/agentshield_0.2.1703_linux_arm64.tar.gz"
      sha256 "25da817531d73f23796df364f2c6aeef9f313ee2d12589fa09a228bdcadf014c"
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
