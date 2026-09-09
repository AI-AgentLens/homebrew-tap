cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2099"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2099/agentshield_0.2.2099_darwin_amd64.tar.gz"
      sha256 "47d5bd2eac8f607e0ef8edd8a8cebe12fdf716720a4827c09f8e4f990d0fc771"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2099/agentshield_0.2.2099_darwin_arm64.tar.gz"
      sha256 "33083a9b16fd3cb0f3b24bc6d88ccff62801b78f419297294eb545b0fda89497"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2099/agentshield_0.2.2099_linux_amd64.tar.gz"
      sha256 "a3f7f1f383456eb23394ed91bfda4d21683c790cc8e38a185feae069efb4f302"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2099/agentshield_0.2.2099_linux_arm64.tar.gz"
      sha256 "29c407108363719bddd3faca25ed92720f3cc3a6db1f694d066a68dc8209ca88"
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
