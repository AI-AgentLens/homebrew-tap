cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2007"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2007/agentshield_0.2.2007_darwin_amd64.tar.gz"
      sha256 "9adfc5e02030d16c834e870badf0e09012a209366c22378dfd0f404e737aa978"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2007/agentshield_0.2.2007_darwin_arm64.tar.gz"
      sha256 "787c7a41162eaa701d8fab8255a8ba803a1afa1c030c97f309298cf889273126"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2007/agentshield_0.2.2007_linux_amd64.tar.gz"
      sha256 "5009af516f123ec3de744e5b70c662ef1b8e66e135b11fe4ce461de7750f0edb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2007/agentshield_0.2.2007_linux_arm64.tar.gz"
      sha256 "1db662710d6c8717ad6058313e71ea58d5dcc4d9b2f00173a66f77cef5186f74"
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
