cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.668"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.668/agentshield_0.2.668_darwin_amd64.tar.gz"
      sha256 "4afd098f71a16bccdcbf72bf26ca09689e3981728bb311bf21086b858d4471f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.668/agentshield_0.2.668_darwin_arm64.tar.gz"
      sha256 "a2b183d24218892272ef87e0e5dc2de3cbd768110603831c28dff706d2e72bd8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.668/agentshield_0.2.668_linux_amd64.tar.gz"
      sha256 "af280455297affb37253e1e9f9a01263cdae58e80ef1c82519fe68bf7174728d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.668/agentshield_0.2.668_linux_arm64.tar.gz"
      sha256 "576ce7096147910b4b2af90f2e72409639e7ca23f466305145b2f2d7d2d42cc1"
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
