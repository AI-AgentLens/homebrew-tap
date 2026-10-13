cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2419"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2419/agentshield_0.2.2419_darwin_amd64.tar.gz"
      sha256 "3248525c36a223709150d88421513b5513fb2aeb700fbdfdcdff0daa1eedf089"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2419/agentshield_0.2.2419_darwin_arm64.tar.gz"
      sha256 "81c4f2e07d7290b628df7d182d2774a4d9c4df848e2f139f82e2525f138c3ef5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2419/agentshield_0.2.2419_linux_amd64.tar.gz"
      sha256 "da3bd64755ce373273a2a6367327b766b39543c0145d24ff8e3f959c25500b2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2419/agentshield_0.2.2419_linux_arm64.tar.gz"
      sha256 "b1f61069c7f95367e4d7d23aeb755a8b58d04a5a6336196f6ccaf42804094dd2"
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
