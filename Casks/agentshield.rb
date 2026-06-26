cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1452"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1452/agentshield_0.2.1452_darwin_amd64.tar.gz"
      sha256 "d1987d48627a7e8ee1c51865034f5cb0a6d1629b30c3510d80f3548a007f5843"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1452/agentshield_0.2.1452_darwin_arm64.tar.gz"
      sha256 "eec7d677a1d7b8ce3e03c0486af052c08f265c448f9588728b914c5424af30e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1452/agentshield_0.2.1452_linux_amd64.tar.gz"
      sha256 "eacd26e752ee18898dc06ac5c69decc58dc73bdd5d2ff5f525a5f28a3e4c32ac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1452/agentshield_0.2.1452_linux_arm64.tar.gz"
      sha256 "50aa0e4cdc5538297464d1028e6a39cd1e95f048dd9dd0e1f25b73de88efdc93"
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
