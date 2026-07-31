cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1762"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1762/agentshield_0.2.1762_darwin_amd64.tar.gz"
      sha256 "fa25940920a9064dbd0cf63081d05a877c579e7b6d35fa259e6ff53a1006a52e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1762/agentshield_0.2.1762_darwin_arm64.tar.gz"
      sha256 "dcd4c1e5dad720c0dc290a6341461b416e1cbd88868f561fda329b7a5604b129"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1762/agentshield_0.2.1762_linux_amd64.tar.gz"
      sha256 "8e8db99e6abe981735ffca54855959f535265d2ea748390952d0a5e58ca3b3c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1762/agentshield_0.2.1762_linux_arm64.tar.gz"
      sha256 "885b66bea87f3b1f00924681e15b61e1346e90a7e5451682c0cdccc02fccb820"
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
