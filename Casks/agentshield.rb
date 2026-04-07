cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.478"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.478/agentshield_0.2.478_darwin_amd64.tar.gz"
      sha256 "56ad87dd4b9c8bd136ff5eb1a1b415849d771de49820a6c7cf51e2f82d1fc72a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.478/agentshield_0.2.478_darwin_arm64.tar.gz"
      sha256 "54fcaee7da3e410b5cd474fb8410c723023031b7b647879cbd0eb641d5b6d22f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.478/agentshield_0.2.478_linux_amd64.tar.gz"
      sha256 "e25ce744a585a64ca83a4c2b7683ab6143f9225ca3b0d6c671b35987d4a26fae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.478/agentshield_0.2.478_linux_arm64.tar.gz"
      sha256 "66b9f84845e6cd484332504bf1ed703d3c9c83a799ac691f6e45db06b88fe491"
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
