cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1275"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1275/agentshield_0.2.1275_darwin_amd64.tar.gz"
      sha256 "39c33f9eafd15ba6d77cd3d9b9c0efb494f4ded7d014e8af34eeef1d5f97a96c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1275/agentshield_0.2.1275_darwin_arm64.tar.gz"
      sha256 "ec16e634a2c9ef47b51082ea0e4bf44db8624b31f9899ab27051dba67bc6378f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1275/agentshield_0.2.1275_linux_amd64.tar.gz"
      sha256 "ae9fb8f730bd3d6545fa1e60461d8f1ad08df5289b69bf0a4e15e0852385fe0b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1275/agentshield_0.2.1275_linux_arm64.tar.gz"
      sha256 "e4e95c6fc7a8bcb18e3ba5e8661e5014dd53e578feccb14ffb35e4cd9434c9aa"
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
