cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.105"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.105/agentshield_0.2.105_darwin_amd64.tar.gz"
      sha256 "1ee2a96d64b0f9ced85f20e479e1eded3f3cd86e887362aca5531a490ef388aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.105/agentshield_0.2.105_darwin_arm64.tar.gz"
      sha256 "7c633d2d1884e9372ce20e4ba5060a2e1705df811a94c5eea14d9190d37e7ceb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.105/agentshield_0.2.105_linux_amd64.tar.gz"
      sha256 "5dcf9fc0fbcdee98ce218583f89088bb745f2eae2af4c510241a43de46d0dda0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.105/agentshield_0.2.105_linux_arm64.tar.gz"
      sha256 "f6bca8b2919edca58dcf0ccb4da744b43a554b2bf350eb4c4e0977defa365f16"
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
