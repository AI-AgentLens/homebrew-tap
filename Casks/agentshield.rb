cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1882"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1882/agentshield_0.2.1882_darwin_amd64.tar.gz"
      sha256 "9257b0c9dfdb77bdce306a982af49f2cf31f01396ef0ecd5d3494fe6753eaca0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1882/agentshield_0.2.1882_darwin_arm64.tar.gz"
      sha256 "516ac6f004b795227c935dff3c50fae00ca8803c16025eb973068e877f682963"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1882/agentshield_0.2.1882_linux_amd64.tar.gz"
      sha256 "71fa4da2bc9ef2bb463293a193ed6fe57608cfc28981203854430974afc3bfbb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1882/agentshield_0.2.1882_linux_arm64.tar.gz"
      sha256 "1f6bb3b7c8ed61617da4a8c6991d00a143d8f45c74f2f85bce10129728dafce5"
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
