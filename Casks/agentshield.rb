cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2185"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2185/agentshield_0.2.2185_darwin_amd64.tar.gz"
      sha256 "c4c1a265ae68277b0687d8341d0c8c9b162ac200cfe037d9e6d4e9d00579f021"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2185/agentshield_0.2.2185_darwin_arm64.tar.gz"
      sha256 "caedf1d7aa5ec12fee792d632dad3137fafbf23a1c4c42f824b27c6dd2c8402e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2185/agentshield_0.2.2185_linux_amd64.tar.gz"
      sha256 "c787bf49e9011984da02eda9da5df7400f170a11df922cf11655112417295362"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2185/agentshield_0.2.2185_linux_arm64.tar.gz"
      sha256 "84b3b76f6aa60d996a0515471b765ada41601a9d585367a55aa639c0fd639f19"
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
