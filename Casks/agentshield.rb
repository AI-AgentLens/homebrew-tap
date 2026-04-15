cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.596"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.596/agentshield_0.2.596_darwin_amd64.tar.gz"
      sha256 "7f69ff5aaec15a33d46d64b6184c2ac885c3a4cb1b4c1a3c8376a6e978e77fd1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.596/agentshield_0.2.596_darwin_arm64.tar.gz"
      sha256 "59d6131e8208159cef3c2c7068fcc3f80c2e8a02e8b07e2d68e4af06eb8d20b9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.596/agentshield_0.2.596_linux_amd64.tar.gz"
      sha256 "eaf955bba312a6b4f721958d8fbbbbab47671e90e57c3c0b5c41898f30e1883f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.596/agentshield_0.2.596_linux_arm64.tar.gz"
      sha256 "0078acd54b38857f9881a21ee87a666a0da6b29ccdec3b1aeaa44f74a60bf75f"
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
