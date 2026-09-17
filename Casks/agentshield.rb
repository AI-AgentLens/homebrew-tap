cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2169"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2169/agentshield_0.2.2169_darwin_amd64.tar.gz"
      sha256 "ad5ea9825a454b64b8765437ec0a2de83a1624ba12d59064bb221a167c3508f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2169/agentshield_0.2.2169_darwin_arm64.tar.gz"
      sha256 "4b6b5dddcb04fb81f5f7d6e3eccf0fe50de848aa8627ebc4d8c6f1c3cc7fca48"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2169/agentshield_0.2.2169_linux_amd64.tar.gz"
      sha256 "cfb6517c93eaef277be71aa57f3c8a41476924af26017c136b230e306684c96f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2169/agentshield_0.2.2169_linux_arm64.tar.gz"
      sha256 "05bf1f1d4a354887b0682286d3df611e7b41d384fa6f60a7c06825cc32e16cd5"
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
