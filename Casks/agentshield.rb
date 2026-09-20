cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2194"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2194/agentshield_0.2.2194_darwin_amd64.tar.gz"
      sha256 "fdbf473fbc9251486c13fd90ba4072dc51c0d4b20f63ab7977da0e89ec2b5d05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2194/agentshield_0.2.2194_darwin_arm64.tar.gz"
      sha256 "191b8fa1f00fd2ff7099ee654752494b6c21f46dc45f6f2cdc4830fa5329067a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2194/agentshield_0.2.2194_linux_amd64.tar.gz"
      sha256 "0411659d62da0d2ef413ec5d426b81cef86a6ebd10c8bfa6d974bb73d9540342"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2194/agentshield_0.2.2194_linux_arm64.tar.gz"
      sha256 "6d47d1e8e6f8d4ffe4a4513a1e6f93596089bf10f510d7d62228f2c6e809ce01"
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
