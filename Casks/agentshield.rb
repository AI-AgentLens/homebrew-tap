cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1608"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1608/agentshield_0.2.1608_darwin_amd64.tar.gz"
      sha256 "5ca66d3245f1a0cc9ff62fe0a79ad91451c0074e2654157e53f3909a33a8c16c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1608/agentshield_0.2.1608_darwin_arm64.tar.gz"
      sha256 "2f83e6949f561eade58a884b6e078a048d6ee0e07203886ecd0ce821ba7acf40"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1608/agentshield_0.2.1608_linux_amd64.tar.gz"
      sha256 "39eb55652e0b494e123aed3278242c2059f02d845c61984bcf6117916a19cef8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1608/agentshield_0.2.1608_linux_arm64.tar.gz"
      sha256 "69fb8ffddaadd46b81deebc07d839002239eb47511e915cb365e6d147d0296d9"
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
