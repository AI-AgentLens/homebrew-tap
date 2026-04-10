cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.523"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.523/agentshield_0.2.523_darwin_amd64.tar.gz"
      sha256 "2bcef65c982df11dabef40ddbe18487298bff582ee5d67a2bcb19646ee7c7477"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.523/agentshield_0.2.523_darwin_arm64.tar.gz"
      sha256 "4e8f2a59295085e04c5fec6e0e192887ae3de5e4fcb0292974b91619b50ec33f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.523/agentshield_0.2.523_linux_amd64.tar.gz"
      sha256 "2a4c190225d46d84b01eb5c123a7fdbe54e7a64fbed09908fe42667bd2a8366a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.523/agentshield_0.2.523_linux_arm64.tar.gz"
      sha256 "6e94112ad6aade3c282b53ac25199bcdac18f8ea91f6a7c7c842ef3b471b1e17"
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
