cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1511"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1511/agentshield_0.2.1511_darwin_amd64.tar.gz"
      sha256 "9863991d88be31d7775b9e8fe116d576edb17646201c2130037bcf4387135d21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1511/agentshield_0.2.1511_darwin_arm64.tar.gz"
      sha256 "9d5279fbcb7ea726f2f6bc5a565a246494fb198db1f9704b04f75abefb802507"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1511/agentshield_0.2.1511_linux_amd64.tar.gz"
      sha256 "bbc33d5bc54fde32d0de081986d6dee9c85d5e1a437215aa85e9288628cf642b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1511/agentshield_0.2.1511_linux_arm64.tar.gz"
      sha256 "e126f3852fe29c7b240d39e0fd251892d15e882a2ea7d79aa94f1369a382562a"
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
