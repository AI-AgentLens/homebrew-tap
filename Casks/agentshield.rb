cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.165"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.165/agentshield_0.2.165_darwin_amd64.tar.gz"
      sha256 "b5575f7248cbde88f6a53d6b8104088a94ff00445c9bd6725d850b57ee466c8e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.165/agentshield_0.2.165_darwin_arm64.tar.gz"
      sha256 "9370f1f58dc1492994a8718972225bbde2fded3dbc954b2cf6b276b549a30bbc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.165/agentshield_0.2.165_linux_amd64.tar.gz"
      sha256 "4453d299539e0a0f4f1e606bd8e255b29498cccd2c0a6fcf0fb9063c3ed3fed3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.165/agentshield_0.2.165_linux_arm64.tar.gz"
      sha256 "7cd1b40349e374fd2426febd9559947a92e8dd023e76060c87dd284845eca51f"
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
