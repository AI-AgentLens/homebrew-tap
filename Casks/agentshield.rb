cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.123"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.123/agentshield_0.2.123_darwin_amd64.tar.gz"
      sha256 "55375e4d6caa0216c3645bc37b1d00871ac44a45795ad6d91b4170718e54ce34"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.123/agentshield_0.2.123_darwin_arm64.tar.gz"
      sha256 "3212884fb72f94f8be0f4eb49c94e64a8924cdc243be9c4b0152e50a269d32ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.123/agentshield_0.2.123_linux_amd64.tar.gz"
      sha256 "798fec213ef56c309b1db86dedb9293a1537a044ee09c30c2874558c15603fd1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.123/agentshield_0.2.123_linux_arm64.tar.gz"
      sha256 "e4bf0128d431041753c8afd14c09dd78cc87888f11852fcf9b6a122886f2cfa0"
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
