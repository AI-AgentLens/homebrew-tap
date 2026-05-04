cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.877"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.877/agentshield_0.2.877_darwin_amd64.tar.gz"
      sha256 "7e041c5c1d8d78b4790c51586480367276cacf3a57978e382773b1d7b72e6fc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.877/agentshield_0.2.877_darwin_arm64.tar.gz"
      sha256 "75970ced71c0d27a27d6c2469d7e2c51e4c8b1a718a1f61c23228a7a5bc238ad"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.877/agentshield_0.2.877_linux_amd64.tar.gz"
      sha256 "7b09152f64e98321d90b67ed57cdf653fa3498a15a9a6771b8c66d888bd8c70b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.877/agentshield_0.2.877_linux_arm64.tar.gz"
      sha256 "a131f562cf2cc8899da4e3626b3431b85daae3724179e3098e0ac83445bdd00c"
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
