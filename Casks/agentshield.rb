cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.89"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.89/agentshield_0.2.89_darwin_amd64.tar.gz"
      sha256 "c50abaaf447436552476a163716848bb3da6a17007bb84fe8b2c2e4e2686bc3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.89/agentshield_0.2.89_darwin_arm64.tar.gz"
      sha256 "55dc6610a87ef46b4d1a3944f59b5bf1e4691b80e8dec3f103a7b603ed32a159"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.89/agentshield_0.2.89_linux_amd64.tar.gz"
      sha256 "86d30f15feeafbd31bc16ed15a99f5830c206e817bdb3e8407ad8317a55790da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.89/agentshield_0.2.89_linux_arm64.tar.gz"
      sha256 "ae8b7ac779721818f1a686644fa343ce6d100a7a6b777c52eef78955664b07da"
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
