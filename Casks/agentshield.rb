cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1881"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1881/agentshield_0.2.1881_darwin_amd64.tar.gz"
      sha256 "2e7c41c5f87179871237d0e8994397c6ed40000e2704f612b9b83c4a93509a8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1881/agentshield_0.2.1881_darwin_arm64.tar.gz"
      sha256 "6b5eb56e0396fe5e55ae980fd2a6790dac719a731a89cbf786089d7b6ebb542b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1881/agentshield_0.2.1881_linux_amd64.tar.gz"
      sha256 "9f04ae6c2f6546a6b546e35338c37e8fb9f37a8ab007447705f4e8ae74f249e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1881/agentshield_0.2.1881_linux_arm64.tar.gz"
      sha256 "36eaaa81a43f1dfca7e6cdae37aa8e6cc35fc3ee8a9b14d2b834d8e29cae2478"
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
