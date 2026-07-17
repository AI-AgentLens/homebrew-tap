cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1660"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1660/agentshield_0.2.1660_darwin_amd64.tar.gz"
      sha256 "69147e62707df37787e15ad1a33e066baba88ef22d635b89d586ef4c18ae353b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1660/agentshield_0.2.1660_darwin_arm64.tar.gz"
      sha256 "ba03a1db103dbeae74f08da690cedba156d0323841945589fa65823ebb074b13"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1660/agentshield_0.2.1660_linux_amd64.tar.gz"
      sha256 "11e6d6ec040262d21ee39134ebaa6a9ab1ceea7c67082a3f97136916796778f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1660/agentshield_0.2.1660_linux_arm64.tar.gz"
      sha256 "ca1ae163e70f2e807e408eee557658a57f2cb10fe3e6427c379c6fec989dd67f"
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
