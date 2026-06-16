cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1340"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1340/agentshield_0.2.1340_darwin_amd64.tar.gz"
      sha256 "65a0845fb3c2ace43bce06920e29943d0c8925143c52d36d5f2743f2433c0cc1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1340/agentshield_0.2.1340_darwin_arm64.tar.gz"
      sha256 "671a1df0b38ab4dd6ac304588f777d593ce06bf4574e0eb01f4490117a37ff59"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1340/agentshield_0.2.1340_linux_amd64.tar.gz"
      sha256 "6de95f0a0ee2734f7db386d54a5aa8925af061e8816552eeb7a736dd29b4bd0e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1340/agentshield_0.2.1340_linux_arm64.tar.gz"
      sha256 "ec2b5bcabfddf98fee64315b1869c6d4fe32a5f24388787d54a331d58f2b4abd"
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
