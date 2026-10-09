cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2384"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2384/agentshield_0.2.2384_darwin_amd64.tar.gz"
      sha256 "01d567e669b5cae79ca82488a676bd32a825131ad6d134f41e684074035a29dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2384/agentshield_0.2.2384_darwin_arm64.tar.gz"
      sha256 "264c6f100004d2241c7586e45df7da249e41b6f1710f171163bf7bbf4b61ad78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2384/agentshield_0.2.2384_linux_amd64.tar.gz"
      sha256 "2d5451ec8f6d41295fafe17a143eafa731afabf8f62f44b2bd6613d1f2ecfd4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2384/agentshield_0.2.2384_linux_arm64.tar.gz"
      sha256 "9e3abe0c09dab14c4f93824e8b7ab04c579c0f14eb2c03c350ed77cd5d5a8d81"
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
