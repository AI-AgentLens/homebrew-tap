cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.546"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.546/agentshield_0.2.546_darwin_amd64.tar.gz"
      sha256 "da05ee762e4752fdd9e5bee34fa0d34eeb58c0f028737cb7cf452ac4cbd54aa3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.546/agentshield_0.2.546_darwin_arm64.tar.gz"
      sha256 "895a548e4817d6fd0776bde31e208ac59c80f12965c4dc354601846e74fb9208"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.546/agentshield_0.2.546_linux_amd64.tar.gz"
      sha256 "f08fd27ba822f1bacd65c1b16adcd29661ec0c503401fa09b74419339aa63e70"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.546/agentshield_0.2.546_linux_arm64.tar.gz"
      sha256 "60b27372d5d6fa706be7e7833812769391a1a1345e4ec6b5e6664b9a52eb9cb5"
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
