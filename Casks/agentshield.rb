cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.209"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.209/agentshield_0.2.209_darwin_amd64.tar.gz"
      sha256 "51f3fabe03f86e2a813f3c7de2b8080b521fca7526fd0b35b95f439e8993acdf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.209/agentshield_0.2.209_darwin_arm64.tar.gz"
      sha256 "53fdf62855e6f208bf17221e565c01758ba6dfbb28f63f40be2286607639ac7e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.209/agentshield_0.2.209_linux_amd64.tar.gz"
      sha256 "b6a55aaf04a5c5a7c59bdb77f1b531b8cb3a0fe25e44f9cc12dc0a64442d4147"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.209/agentshield_0.2.209_linux_arm64.tar.gz"
      sha256 "7b3d2ffa4ff10f1b47d7b296394c8080d08fdabed29c7a8e2ba6c66624d870c4"
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
