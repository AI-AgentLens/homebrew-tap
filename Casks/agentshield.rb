cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.958"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.958/agentshield_0.2.958_darwin_amd64.tar.gz"
      sha256 "2fc8638573088de93697dd91219974cfeb3ad43e69be223d6d09b1e12aed2b60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.958/agentshield_0.2.958_darwin_arm64.tar.gz"
      sha256 "b9e4b2e28db784674749286502de074b2b8fb719187d3659fa7e6066871f04d6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.958/agentshield_0.2.958_linux_amd64.tar.gz"
      sha256 "3e5551bf7300c159da8179354726eaa0ad6a9179b1193f203db9bb8b2b608c5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.958/agentshield_0.2.958_linux_arm64.tar.gz"
      sha256 "bf349af939b6b658bec17af7ed8e9a1a49dfb607dc1067ace0b24b76c1062382"
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
