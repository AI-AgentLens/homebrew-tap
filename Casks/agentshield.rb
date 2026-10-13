cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2422"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2422/agentshield_0.2.2422_darwin_amd64.tar.gz"
      sha256 "ffcbbb7a85ce3ac32e55afb6f226152b35316a166fe31a9722d7f3227bde430d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2422/agentshield_0.2.2422_darwin_arm64.tar.gz"
      sha256 "530f1faff9098f0d97cd32d593a359ff5cd33ff2da579a655b87ccbf95dd6d38"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2422/agentshield_0.2.2422_linux_amd64.tar.gz"
      sha256 "55c86a2ea7fb263e5f3b3c06cb755bd6208f7ede8eea9f9fa807899e6159aecd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2422/agentshield_0.2.2422_linux_arm64.tar.gz"
      sha256 "3756465e6bb4db5b753bb5ba599d047eddb1ced3c018246eae3f52af9ef6bd38"
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
