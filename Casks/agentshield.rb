cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.723"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.723/agentshield_0.2.723_darwin_amd64.tar.gz"
      sha256 "967953c7946438c9c6ac5cc991c968029d34e289e30cc2f40dc48ae8f97ef67c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.723/agentshield_0.2.723_darwin_arm64.tar.gz"
      sha256 "5a264c02f50bceba9a987842b8f355d338b48ccd1525bcc59f60e08fc18cd6af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.723/agentshield_0.2.723_linux_amd64.tar.gz"
      sha256 "780636bb629956c249563aa3908d726732aaf8691ddf072bbd6dcd4ea1a1bcfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.723/agentshield_0.2.723_linux_arm64.tar.gz"
      sha256 "83d6516a4798762e5ebff559888d88e3f2f2e877a4ca2e9d27b3e60e83485573"
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
