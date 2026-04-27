cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.776"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.776/agentshield_0.2.776_darwin_amd64.tar.gz"
      sha256 "7b39a85d78ab4218d58e8f247c57674b085c29c9daecf3ba93d36e3d3f13e325"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.776/agentshield_0.2.776_darwin_arm64.tar.gz"
      sha256 "e17bfc4241c8903fa03839484ddde3ac3b121b4e3c4e8a8431fa4c0478b33752"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.776/agentshield_0.2.776_linux_amd64.tar.gz"
      sha256 "c5627645b93ab211f1b894fdb881fc24405724cbad6d88bfc4b0a47f940cf28b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.776/agentshield_0.2.776_linux_arm64.tar.gz"
      sha256 "a295dce234857c45100088437519dd7ced90a21e423591ded805850ac10db42c"
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
