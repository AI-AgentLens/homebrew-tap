cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.990"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.990/agentshield_0.2.990_darwin_amd64.tar.gz"
      sha256 "9da69755d74b6e035a14fd05dea50b1abe75f8c1526197e6e03e48e84dfc6153"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.990/agentshield_0.2.990_darwin_arm64.tar.gz"
      sha256 "3308857021b75139cc36e1709c0fc93134bc187430ece61868e56d7d47c5546e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.990/agentshield_0.2.990_linux_amd64.tar.gz"
      sha256 "055b243d03e7ff99c09f6c1dfd146b559135876e9da1c3771ab35a63c89dc28f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.990/agentshield_0.2.990_linux_arm64.tar.gz"
      sha256 "b4d38c56ab5ada8ac28834f7e3b66d817d667892d8af9c2f6b87c277b58b81c0"
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
