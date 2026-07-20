cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1697"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1697/agentshield_0.2.1697_darwin_amd64.tar.gz"
      sha256 "cc3d469689f39cc909766f1b7325d07724e84147b2e8db956fee6379de36b4f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1697/agentshield_0.2.1697_darwin_arm64.tar.gz"
      sha256 "0c2288d0d81bd963274dc9f1e33548e3adc8ea4699f32d0aad34e01fa9ffca8e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1697/agentshield_0.2.1697_linux_amd64.tar.gz"
      sha256 "6a8ba1d598afd762728d30ce79db2df5e96073aa89aae7ca217f74903d13e76f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1697/agentshield_0.2.1697_linux_arm64.tar.gz"
      sha256 "7586ffdaa216c0fdca106bd7b7062bcc2edcc6e9683f234e6f62f14c111ea540"
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
