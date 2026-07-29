cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1756"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1756/agentshield_0.2.1756_darwin_amd64.tar.gz"
      sha256 "60121b5644fb2a70af71d8fc02a76b2da0e34ed60a23434a3f816e33308226f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1756/agentshield_0.2.1756_darwin_arm64.tar.gz"
      sha256 "51ca87d8f85807fafb392d460b695c4d540e1f56037d9b101c0671de9f480fa2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1756/agentshield_0.2.1756_linux_amd64.tar.gz"
      sha256 "c0903ec36649d43dfaaf4c23512cfa14f8a311e6af478c26255e81ee117a5b18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1756/agentshield_0.2.1756_linux_arm64.tar.gz"
      sha256 "58971d4ce1b66cbf1efa3ec2bf4bc32141607b2ac53f9fc7fb3167a083b7e8dd"
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
