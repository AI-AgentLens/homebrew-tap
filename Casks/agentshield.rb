cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.951"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.951/agentshield_0.2.951_darwin_amd64.tar.gz"
      sha256 "b5e3b86dcb34749ce414a0a1117ab080653033fb486e5a12c4d03423d9c5e8ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.951/agentshield_0.2.951_darwin_arm64.tar.gz"
      sha256 "3916747188dc89ee46f1fff61fb2f595d4fd4fb2a798bb1ba104b18e4629ed47"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.951/agentshield_0.2.951_linux_amd64.tar.gz"
      sha256 "cb4db7687a8f476ec4240d509a0c5d7adec9d81bb0cc63465874a21418f0ff90"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.951/agentshield_0.2.951_linux_arm64.tar.gz"
      sha256 "96a558fd34daa871e3b99572eef0036dbbe808149596fafc69423e2bbb3cb87d"
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
