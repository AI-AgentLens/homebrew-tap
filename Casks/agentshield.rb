cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1848"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1848/agentshield_0.2.1848_darwin_amd64.tar.gz"
      sha256 "e8b5b2c2a78caac49b90aeaf647d0c2abece5e824ed76f19c1570f110f162064"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1848/agentshield_0.2.1848_darwin_arm64.tar.gz"
      sha256 "d2f4a56370ed0a905d48f39d1facf8bff3956b5d4b62203435fe136a9c242e53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1848/agentshield_0.2.1848_linux_amd64.tar.gz"
      sha256 "52c1e1af4dfbfea9c5b0b5db8f28fa5378d0ad0079667a520d056c574a0a9e8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1848/agentshield_0.2.1848_linux_arm64.tar.gz"
      sha256 "7f4c0017a0f1fd2caa6c8a36ae681b779689c347cd4c3508246aa9356330d5aa"
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
