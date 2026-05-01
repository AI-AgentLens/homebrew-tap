cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.841"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.841/agentshield_0.2.841_darwin_amd64.tar.gz"
      sha256 "4d4e4fffded6ce6f86ba3fc32b9304d0b6454407974ad05a8535623986da48f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.841/agentshield_0.2.841_darwin_arm64.tar.gz"
      sha256 "b0454f7b72bee5e18e9e5d9face1758a1b079ee5500af00c0cab3fefda3d7053"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.841/agentshield_0.2.841_linux_amd64.tar.gz"
      sha256 "56deaa80be1ede7113e2cb74ba2fb2fcdb19d297a744e8ca7fd60b5794d8f20c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.841/agentshield_0.2.841_linux_arm64.tar.gz"
      sha256 "18a8ae7001b8665e5924a6de55dbe3c12b943e7a7867069373baf808954b6775"
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
