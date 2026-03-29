cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.185"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.185/agentshield_0.2.185_darwin_amd64.tar.gz"
      sha256 "c20083cb2ae5e06cf10f5b3f94cb83a6755d81cb60379c2e6f66d4bcc954988e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.185/agentshield_0.2.185_darwin_arm64.tar.gz"
      sha256 "82bad35447e76446a6a423996d0a004ba7e31b50f12f9efd0d437285227b908d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.185/agentshield_0.2.185_linux_amd64.tar.gz"
      sha256 "b58207c2b7a9e27f3130e51239c53821f0575c779511c0d718a4f9fd1920c316"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.185/agentshield_0.2.185_linux_arm64.tar.gz"
      sha256 "bae41bcbfd5b91e709bd40b44dcbc93683607813cf9bace948e9161c2cb1f38a"
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
