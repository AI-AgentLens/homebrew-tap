cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2316"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2316/agentshield_0.2.2316_darwin_amd64.tar.gz"
      sha256 "12568bb053d9863cd2367ab9066af13c6757a1e1423f716c48997c84ea3145c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2316/agentshield_0.2.2316_darwin_arm64.tar.gz"
      sha256 "042d4ff5feaad45cb26005398e29b65ea76a9e2e166a828dce6edcb730c3526f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2316/agentshield_0.2.2316_linux_amd64.tar.gz"
      sha256 "feb02c3f2863c4dfd019997f9248bacff1adc339177e5d35798e610e2d7c0c25"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2316/agentshield_0.2.2316_linux_arm64.tar.gz"
      sha256 "4278cce2e2c9b8f51cc6236160142957bc5ef82d277548b9f365d719ac9d03be"
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
