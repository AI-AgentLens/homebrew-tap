cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1093"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1093/agentshield_0.2.1093_darwin_amd64.tar.gz"
      sha256 "643b35ddcb779362f1159210730c4ea74832e77924f2b6dec99e5ea77757c630"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1093/agentshield_0.2.1093_darwin_arm64.tar.gz"
      sha256 "1c2c68b773aa3ad81ee96e18da3044724393a471b77cf5346ff26e354d716d24"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1093/agentshield_0.2.1093_linux_amd64.tar.gz"
      sha256 "32c3a805554dcf28b49c85507ae3551da5851ead007e3c0f731e76c7216dfd56"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1093/agentshield_0.2.1093_linux_arm64.tar.gz"
      sha256 "5542b60bf50a782017d028f3cf78cd881302415f1c31ffa4aaf26464dc8fd567"
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
