cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1262"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1262/agentshield_0.2.1262_darwin_amd64.tar.gz"
      sha256 "8cb4eed9c7522bde8549bc2fc4fbc2aa10f6ed26178208a5d0503a14aea4065e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1262/agentshield_0.2.1262_darwin_arm64.tar.gz"
      sha256 "2bdb248e424f816ad6433dcf700e32af12a16c1a22f0291e6faaf4dedf6914af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1262/agentshield_0.2.1262_linux_amd64.tar.gz"
      sha256 "42c3a044bdea42957da860a3c78b746427d5b531cb12cedf4083c4cd66c0fd0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1262/agentshield_0.2.1262_linux_arm64.tar.gz"
      sha256 "5bc387551661341e7e94943e26fd5e154d50775f6927b1977192d60e97a57a15"
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
