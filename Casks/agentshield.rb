cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.141"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.141/agentshield_0.2.141_darwin_amd64.tar.gz"
      sha256 "277cc9d515023a50cb3c29996c740e98fb1c973dc1c9306ec83462356efd126d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.141/agentshield_0.2.141_darwin_arm64.tar.gz"
      sha256 "0565bee3b2658399653d1514bfe11984032d8549356fc36e765c2d7b11722201"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.141/agentshield_0.2.141_linux_amd64.tar.gz"
      sha256 "935b0b76d0741052e45fdf9986aaffb47b17ff5a698a71d46aee46055bf0b5dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.141/agentshield_0.2.141_linux_arm64.tar.gz"
      sha256 "3fe7c23d926304d419fa596b9903dec37a97f1b7042105461d40a6439bb17845"
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
