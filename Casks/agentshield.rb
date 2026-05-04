cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.875"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.875/agentshield_0.2.875_darwin_amd64.tar.gz"
      sha256 "44f554c651b0260b2a772c808a6a45b1de75f56d191cc0678d8d4e5017546c86"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.875/agentshield_0.2.875_darwin_arm64.tar.gz"
      sha256 "474ef4d498759cc29ce08ef7d00053a6ae06a0bda4835cc592208d9757a50a78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.875/agentshield_0.2.875_linux_amd64.tar.gz"
      sha256 "df8aa60944972309997e51a1494045d90d0dfbfbebda5db43cf2de0c64916a62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.875/agentshield_0.2.875_linux_arm64.tar.gz"
      sha256 "5ff4cf25d2e0e916d8bbd8f0185c51cdd880710e82a3e12d8d60aa922cec95fc"
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
