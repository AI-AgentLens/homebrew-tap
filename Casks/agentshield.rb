cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2332"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2332/agentshield_0.2.2332_darwin_amd64.tar.gz"
      sha256 "ebbd5292bf4cdffe5fbf1545c8c51f9af7d0c64fddbeb2374395f05a127c8a75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2332/agentshield_0.2.2332_darwin_arm64.tar.gz"
      sha256 "46027a33b5b26c843b9f753fd5f40e2364e14ba6f732d46f483590c7790d3eee"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2332/agentshield_0.2.2332_linux_amd64.tar.gz"
      sha256 "03e7467f092e9e3a8bef02430bd1d6d706a4aefbcea221f12c896aa2e29f08ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2332/agentshield_0.2.2332_linux_arm64.tar.gz"
      sha256 "7c9e8819ffcce1c74708eb9967654ad741c3a6975e0ec7e480aa360e466699d3"
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
