cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1285"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1285/agentshield_0.2.1285_darwin_amd64.tar.gz"
      sha256 "4da888d55e0041863149733e359106e2c1eaf7fe8ec63a26fd4b2322bbc9e67a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1285/agentshield_0.2.1285_darwin_arm64.tar.gz"
      sha256 "64e974b6cc2e5724d64534911877ee0679dc1aa0296c47476dd04413b49d2ea5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1285/agentshield_0.2.1285_linux_amd64.tar.gz"
      sha256 "c5ecc4a0de3f12e14fa5a5c4cca280ed59f7ab1b348ccea309830d31725e9260"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1285/agentshield_0.2.1285_linux_arm64.tar.gz"
      sha256 "11c444219d380ed3e71398d0b5ae5cc69c3c6d8768e6a96159bbaab57a2954ff"
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
