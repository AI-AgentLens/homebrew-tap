cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1792"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1792/agentshield_0.2.1792_darwin_amd64.tar.gz"
      sha256 "5b7c5c3705242f77a0a4697cf7d1c6a201e7dcab9de36a32c8af6d8f1f6ad956"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1792/agentshield_0.2.1792_darwin_arm64.tar.gz"
      sha256 "25a8352895da2b279526e22b1f8f9c48b821327e521b5a68eefd2790e5f5e713"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1792/agentshield_0.2.1792_linux_amd64.tar.gz"
      sha256 "a1bb3cc4607536673bd32af3ea7966c602d94bf098df1c3328ddb4aa616cf189"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1792/agentshield_0.2.1792_linux_arm64.tar.gz"
      sha256 "167e12eb9b8dc809e55019c04cb4d4e1b4b0876a5ba754e9091261f2c3f12b35"
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
