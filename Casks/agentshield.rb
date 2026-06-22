cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1395"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1395/agentshield_0.2.1395_darwin_amd64.tar.gz"
      sha256 "85e6e413aaae1956a56b85edb9315d4d373525581d3c4475a857e2173d6d206c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1395/agentshield_0.2.1395_darwin_arm64.tar.gz"
      sha256 "cf3a27e35a52d4371d0b46474c1e7a14e9ae9a335f331bb34e73e667e34c1d3b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1395/agentshield_0.2.1395_linux_amd64.tar.gz"
      sha256 "1cf516da78dfebbef369d0e212a94137314316e2b8fbd1f379defb980d2d4064"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1395/agentshield_0.2.1395_linux_arm64.tar.gz"
      sha256 "4ecd7eb20f83bf8fff240eb11684e76a6d367a67604490c629cd30039a935c9d"
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
