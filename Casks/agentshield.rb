cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.721"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.721/agentshield_0.2.721_darwin_amd64.tar.gz"
      sha256 "6d0f16bcf11fead66c0a867adf7dc958a2aad51d1f7ae3f677e3a8b2e9c9f0eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.721/agentshield_0.2.721_darwin_arm64.tar.gz"
      sha256 "d8255b4c12fff0d0269cb2d8086c19d02b1be6c191d7ec766080fefc7b91b5ae"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.721/agentshield_0.2.721_linux_amd64.tar.gz"
      sha256 "becd228f52cac7ad21cd91a7ada9ca43cc6f40e4d2ee020ede3de85c51c1c897"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.721/agentshield_0.2.721_linux_arm64.tar.gz"
      sha256 "ac617a062a367b144ecd97509cc09a538b423a3a08f93be265b153ff209c90fb"
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
