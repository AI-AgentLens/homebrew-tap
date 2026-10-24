cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2515"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2515/agentshield_0.2.2515_darwin_amd64.tar.gz"
      sha256 "9efd760af7046b941959ecd3776065409cf92e9dffd4678059f0ae0b5492effc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2515/agentshield_0.2.2515_darwin_arm64.tar.gz"
      sha256 "32b8e0558eb0522b182bca11c09386ecf58e5357afe90d30b0c1f32293319a70"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2515/agentshield_0.2.2515_linux_amd64.tar.gz"
      sha256 "01f580a5cff43da6349db9d9716c98d0e29701e20a9db249c36f263bb1ac17f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2515/agentshield_0.2.2515_linux_arm64.tar.gz"
      sha256 "0a35e18d33a163a49d33a0859b476e9cb12e6eb0d22da1320d7f4ee6e692f7f6"
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
