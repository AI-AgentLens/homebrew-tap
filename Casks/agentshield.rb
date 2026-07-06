cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1569"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1569/agentshield_0.2.1569_darwin_amd64.tar.gz"
      sha256 "8638d086d2d5b74f3e3d8dccbe5222c6c6a24102c0c8d607ed32c60c04ba4dc6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1569/agentshield_0.2.1569_darwin_arm64.tar.gz"
      sha256 "f89a09dd0b063e642d7bea341433e1641eafba9162ce41f43a17c47fd91ad7ab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1569/agentshield_0.2.1569_linux_amd64.tar.gz"
      sha256 "244d4b058ac76deb8229b10967e30a68447e6d6e64f630659e220b61efb5bf76"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1569/agentshield_0.2.1569_linux_arm64.tar.gz"
      sha256 "2a7a5b0044a99f5d718203324c64f36e351cfdda9f9a44987313b56592eab86d"
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
