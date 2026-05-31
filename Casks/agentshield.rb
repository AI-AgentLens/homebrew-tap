cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1170"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1170/agentshield_0.2.1170_darwin_amd64.tar.gz"
      sha256 "0ea4bb5723d6d21ed39e10da316b5a5140bc471c003c1639e1a8dcbf344d5e0f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1170/agentshield_0.2.1170_darwin_arm64.tar.gz"
      sha256 "fd28510e8fb91ab68739b94f9cb19e7e828860ab438189f52c26f2ce032dab48"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1170/agentshield_0.2.1170_linux_amd64.tar.gz"
      sha256 "7102c99f81b2115646c5cf507c6cc6940cfb5453bd3f010e0132c7087bb9d752"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1170/agentshield_0.2.1170_linux_arm64.tar.gz"
      sha256 "c3992932c23bd9a84150c175f43e5c482f395e85d267309bcafeec7734d70317"
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
