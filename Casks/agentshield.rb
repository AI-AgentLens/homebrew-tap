cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.838"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.838/agentshield_0.2.838_darwin_amd64.tar.gz"
      sha256 "5f2869b928e25bdc12ddbeeccccd279ed1a8bdaeddd157fa5af3f0bb8a22d7f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.838/agentshield_0.2.838_darwin_arm64.tar.gz"
      sha256 "5100cc9bfd6d24af79272e39214eac8b336f7cee3ca72dcd5f17b06825a95651"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.838/agentshield_0.2.838_linux_amd64.tar.gz"
      sha256 "5a68a7dfddc6263de88a0e7bf1cc54807c65a2184a27f83c5e3c95a2bf737a1e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.838/agentshield_0.2.838_linux_arm64.tar.gz"
      sha256 "b0c6bc9dfc33c51c85ef78e769a57b23cfad89fd5c9f154c1b761a929d28d519"
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
