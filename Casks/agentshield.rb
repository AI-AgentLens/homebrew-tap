cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.878"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.878/agentshield_0.2.878_darwin_amd64.tar.gz"
      sha256 "d1f884e60a9f1023a6683157179421ebbc50ef7c27b0f02df386190b6e8ec005"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.878/agentshield_0.2.878_darwin_arm64.tar.gz"
      sha256 "69dca22d3709a742c71ace416be24e3605933d40c32af3069ef274c8a8036dab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.878/agentshield_0.2.878_linux_amd64.tar.gz"
      sha256 "d480fff65fb24f42f02a92dd6f12a46641930f6b1d899e6ce951c129afa73f48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.878/agentshield_0.2.878_linux_arm64.tar.gz"
      sha256 "9a1f24c0e4857b4ea83eed6e443fb49dea7a52b232459a145ccade49ec8662d9"
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
