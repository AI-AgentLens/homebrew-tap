cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2454"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2454/agentshield_0.2.2454_darwin_amd64.tar.gz"
      sha256 "460ef99b3379907dd3d99ab2c734b20152d6bdccbd277eacbcf575b0aeee0e24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2454/agentshield_0.2.2454_darwin_arm64.tar.gz"
      sha256 "ad76f1daaa56ee733adbdb83158f1e21824b896f155c514ef5a4f5fcc381d2af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2454/agentshield_0.2.2454_linux_amd64.tar.gz"
      sha256 "613f99b41ac92848f8cc5182ac8c32cd0e0af7caece28e05bc7c309ccddfecd0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2454/agentshield_0.2.2454_linux_arm64.tar.gz"
      sha256 "680d5fa9b43c32c8f0cb3099381a07a3fbdfd7d3ebe0f4668f9275af8bcf1dfa"
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
