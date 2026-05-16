cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1000"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1000/agentshield_0.2.1000_darwin_amd64.tar.gz"
      sha256 "6970c8e5d390b33c87586369512f59de91fc0d9bb88ddb5b7358e94a9209f535"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1000/agentshield_0.2.1000_darwin_arm64.tar.gz"
      sha256 "1583f436828fefba29db9d274a60744590625e673aae75ed762337672e285139"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1000/agentshield_0.2.1000_linux_amd64.tar.gz"
      sha256 "1539bcc4f26fb7bcbdebfa3438a38ba6e88dc2e09e387dcbdf320f908cf40db8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1000/agentshield_0.2.1000_linux_arm64.tar.gz"
      sha256 "ae7ec5b032332e69841eb5b0bc327a2cecd6fcd974ca59dbfb90a59e2a652858"
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
