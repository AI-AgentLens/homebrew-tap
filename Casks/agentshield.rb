cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.253"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.253/agentshield_0.2.253_darwin_amd64.tar.gz"
      sha256 "1bcff53e53fe50637d86cd3a135bae982a56d2b6e6c9d1f40b3562c578db8cc7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.253/agentshield_0.2.253_darwin_arm64.tar.gz"
      sha256 "d41cd3b85c3664ab22b1d287bccb4ba70e7152f2436ce21bdbb32bc075e026bc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.253/agentshield_0.2.253_linux_amd64.tar.gz"
      sha256 "3c5291817de799ee0a8cff761a8ded71b459777a2821ee61a23601b56ca5b5f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.253/agentshield_0.2.253_linux_arm64.tar.gz"
      sha256 "3dc0f89d7ad1c4804338ed8a865856ee5ae1e90d8d51d2cb86334faf230a7b80"
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
