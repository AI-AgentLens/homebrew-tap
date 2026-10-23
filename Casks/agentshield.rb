cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2514"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2514/agentshield_0.2.2514_darwin_amd64.tar.gz"
      sha256 "5bca05fb5b7de71a2d594194260da63300c4df02768b9f4d894dd1a050fac15f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2514/agentshield_0.2.2514_darwin_arm64.tar.gz"
      sha256 "1c2d510c7079ae39aff8e5377c1e175feb18fe6ba3843cb3d4fd99a2b2e4b3e3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2514/agentshield_0.2.2514_linux_amd64.tar.gz"
      sha256 "431b04355e01d1136e6e345e909cbd60cef822190d97749859a1dea743bb19d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2514/agentshield_0.2.2514_linux_arm64.tar.gz"
      sha256 "9a8f95690efcb8e8b29b0cf380b7059911ccbfa5f7aee44a9aeee7408a924972"
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
