cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1464"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1464/agentshield_0.2.1464_darwin_amd64.tar.gz"
      sha256 "b60378f85854cf47c56db906af18a46b4dd787e265c491d98fc98ad1990ea11d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1464/agentshield_0.2.1464_darwin_arm64.tar.gz"
      sha256 "782ec6a5881279a5ddf8b9336e0ebf2de939cdf8c76c7e3b75fe3abec850f28f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1464/agentshield_0.2.1464_linux_amd64.tar.gz"
      sha256 "44610aeba6adfdc686b2956be8de4a2769e2a651699229b1fc514e74cc1b89ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1464/agentshield_0.2.1464_linux_arm64.tar.gz"
      sha256 "d62be60946563763bba6389d7d3718d0588a4eab52b491bc8c2ba3e35bcc5135"
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
