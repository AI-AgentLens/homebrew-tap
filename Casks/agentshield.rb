cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1136"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1136/agentshield_0.2.1136_darwin_amd64.tar.gz"
      sha256 "56f03822ac73a4f4ccc7e8013e939ba59b88b2d6ee737b7f915a1b8aa92f9e48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1136/agentshield_0.2.1136_darwin_arm64.tar.gz"
      sha256 "62254d2be58c8c49e143468d02fde29d4266bef7776e2f5605ad4c793c21e2c7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1136/agentshield_0.2.1136_linux_amd64.tar.gz"
      sha256 "d55c13adc6b75f6b41708e7de92f2ab521746b7ef82e28c2a674ca6f8b190e44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1136/agentshield_0.2.1136_linux_arm64.tar.gz"
      sha256 "7de5740629039ab5c34e4929b65226f842dcdd1fabf15577d03c420dcf5d3630"
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
