cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1040"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1040/agentshield_0.2.1040_darwin_amd64.tar.gz"
      sha256 "08c8edb0280445dd3f34a2527a28d1eeb6cd8bedc7bd0ede87559ef721ae3397"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1040/agentshield_0.2.1040_darwin_arm64.tar.gz"
      sha256 "af7ea98e98d4006c46814479967ef9e8bb555deced70dcdcf4e712c4e79a3df4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1040/agentshield_0.2.1040_linux_amd64.tar.gz"
      sha256 "876bd5542914c2e63a1dd76df5d9d8268e9fab898a6d95ad3b44233950843a5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1040/agentshield_0.2.1040_linux_arm64.tar.gz"
      sha256 "ec297fe72fa250d64d2e1132d9ba3651ff7e96c3b0863ed75fc7fbe659a2cb5f"
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
