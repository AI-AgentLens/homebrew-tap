cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1450"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1450/agentshield_0.2.1450_darwin_amd64.tar.gz"
      sha256 "1e5c0c0ff52db2fcb968c19547e69e52ca1fcff97c435ca68a5deeeecc8a8898"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1450/agentshield_0.2.1450_darwin_arm64.tar.gz"
      sha256 "9c2e575f6854f14446695cb4a5cc8c37fb7debe04a91e806eb28bc5af6111adf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1450/agentshield_0.2.1450_linux_amd64.tar.gz"
      sha256 "4d5f7e0e858e74e17c8842e8126b10a9cd285a700bd82681f6ae33175fdc511a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1450/agentshield_0.2.1450_linux_arm64.tar.gz"
      sha256 "74fdabd0c1e733a1b84fb670e0a3446798132ee780788100694f8e94a93b5186"
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
