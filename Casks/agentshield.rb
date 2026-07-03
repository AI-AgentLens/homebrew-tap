cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1534"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1534/agentshield_0.2.1534_darwin_amd64.tar.gz"
      sha256 "d7b38ff3706b07a69de69cc8077dac89338ab52dbf3abe09e24c14e757229913"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1534/agentshield_0.2.1534_darwin_arm64.tar.gz"
      sha256 "12158b5359a3f1c5a8e3f4d770d6048d933375f8520fd2a76c5f30eb757607f3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1534/agentshield_0.2.1534_linux_amd64.tar.gz"
      sha256 "924898226d25599a988a144bf327f6d9b810bbcab22e206c8ee11b6bc1778d2f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1534/agentshield_0.2.1534_linux_arm64.tar.gz"
      sha256 "41db412123c074326377b7c9b1473c8661ee24c945e5a69d9a9caf7597c7dc44"
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
