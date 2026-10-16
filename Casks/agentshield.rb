cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2442"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2442/agentshield_0.2.2442_darwin_amd64.tar.gz"
      sha256 "40622d44f4ddbea3a4947abf3871a91a8857ae3299cf85e25babebdb74c8d222"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2442/agentshield_0.2.2442_darwin_arm64.tar.gz"
      sha256 "d6d4f6a0370c2b80e8b1311e34d273efe123048adc8aae3a7c5800dfb43ab7bf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2442/agentshield_0.2.2442_linux_amd64.tar.gz"
      sha256 "2d43420fa53b4435cae8a5366810b59cdadc4924fb115c0fa403b9cb8e3e6546"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2442/agentshield_0.2.2442_linux_arm64.tar.gz"
      sha256 "a547f954de692444bd8f77625d591c4711743558c22b5e99bd227d9e56d2d535"
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
