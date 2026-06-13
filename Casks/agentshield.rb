cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1303"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1303/agentshield_0.2.1303_darwin_amd64.tar.gz"
      sha256 "7a32dac7c7c0986667458e5bc61c866b9116cee89da36311e0ecbb63ec155090"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1303/agentshield_0.2.1303_darwin_arm64.tar.gz"
      sha256 "fc720a9362104f9df5b1c54256da56dcd62a2de82b792b46eb0654490f7b0753"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1303/agentshield_0.2.1303_linux_amd64.tar.gz"
      sha256 "3bb71553bb11856a555ec6381fae99e7f6960987095f731a2b3955c9cb97a3eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1303/agentshield_0.2.1303_linux_arm64.tar.gz"
      sha256 "52d846f5f0fc73fdd83f84b3457f12d7727e0c0061cbdcb1c4cc529a286a232c"
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
