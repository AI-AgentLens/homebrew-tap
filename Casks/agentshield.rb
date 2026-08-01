cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1769"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1769/agentshield_0.2.1769_darwin_amd64.tar.gz"
      sha256 "4bc68792debed61bab50db1343ef2b1c620ad069cf9f682af6cfe896e3e6103d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1769/agentshield_0.2.1769_darwin_arm64.tar.gz"
      sha256 "8de101c65eec023938da7e54126a133ae39f6d636202ab0c2aa24fd613f4e575"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1769/agentshield_0.2.1769_linux_amd64.tar.gz"
      sha256 "558f81ebdddf5700e733ce76bd3891d74fa63f39e6f588eb2afcf0a1061cab32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1769/agentshield_0.2.1769_linux_arm64.tar.gz"
      sha256 "2144cd274d1fa40f5b43e081ae32620b18c66a3da5058d4fa8d628334025aaeb"
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
