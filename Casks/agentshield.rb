cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1015"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1015/agentshield_0.2.1015_darwin_amd64.tar.gz"
      sha256 "17ffd7c047ea84d1658216af203c5099f2a01629c457f9b31b1ee48b3790fbb7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1015/agentshield_0.2.1015_darwin_arm64.tar.gz"
      sha256 "7ba817ca2610401fd24fe05d90b5d72c6685d1ac532b37b289683faa95726d07"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1015/agentshield_0.2.1015_linux_amd64.tar.gz"
      sha256 "0cf1ce61abb4da9b6df70dcaa44fdaa3ee1837d7bf2fa1092da7f90069b41a60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1015/agentshield_0.2.1015_linux_arm64.tar.gz"
      sha256 "b65c206bddcf0d03db54a120c598c936ce34839512fe565f95c058021a4ec6d1"
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
