cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.474"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.474/agentshield_0.2.474_darwin_amd64.tar.gz"
      sha256 "e41dd53ae08141aa0e5dccf0dbce5994a2047c59e4a6bb2cdb536ca879813043"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.474/agentshield_0.2.474_darwin_arm64.tar.gz"
      sha256 "665325dedacb62b9819942a678a57cd19d83f1192b412c0a9c1d89a00b886d3d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.474/agentshield_0.2.474_linux_amd64.tar.gz"
      sha256 "3b546035ef537755117bde5e050cf059c477ad18e7d29629f8cfe2c2e89c2de8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.474/agentshield_0.2.474_linux_arm64.tar.gz"
      sha256 "35cbe087073a0e42961cf29f8375e8a99ee5ee857e2c6f5d99a2abacb36168b8"
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
