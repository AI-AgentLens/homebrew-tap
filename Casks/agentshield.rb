cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2223"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2223/agentshield_0.2.2223_darwin_amd64.tar.gz"
      sha256 "a1d0fe2c0ffe4f347792940662c5eb8833dbdcaa34b035d98b4f7fe0d2b3e9f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2223/agentshield_0.2.2223_darwin_arm64.tar.gz"
      sha256 "11f6fe55ee79aa33ae3a64c4f79624d17dd099bcbe131ef116c23f31c3bdf6cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2223/agentshield_0.2.2223_linux_amd64.tar.gz"
      sha256 "ce062d1ee76c2a91eacf42deee55bde87b012285bf3773dcab048b0c8956c070"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2223/agentshield_0.2.2223_linux_arm64.tar.gz"
      sha256 "7e8f5f83e20064f300e1932bf2fb39158dd93071c0d0d25c23462e394e89b5ba"
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
