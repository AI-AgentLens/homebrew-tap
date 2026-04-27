cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.774"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.774/agentshield_0.2.774_darwin_amd64.tar.gz"
      sha256 "46c20a883353b3042156b22a8f330624e93b3ec120489c6bc7bd568c8240cd8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.774/agentshield_0.2.774_darwin_arm64.tar.gz"
      sha256 "f86fc1d9c9a7fbe7ecbed1de2bd394dcab2f2f0c06e53a3a9697b53fc92da691"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.774/agentshield_0.2.774_linux_amd64.tar.gz"
      sha256 "e6885b021ec830679744f9c598af8d3d36e3a83c41b65c610a4f4eb94e0a0f89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.774/agentshield_0.2.774_linux_arm64.tar.gz"
      sha256 "55cfe0cc3e2d60ff96f4cd94122065007ebe1f746344bf30028ed320a618b10f"
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
