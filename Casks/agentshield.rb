cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1311"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1311/agentshield_0.2.1311_darwin_amd64.tar.gz"
      sha256 "5f4c8b2166150a6e1ab31d825491d5a20144733087a952afd1061df769e372b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1311/agentshield_0.2.1311_darwin_arm64.tar.gz"
      sha256 "7dddf5205785ad64aee7bd5d8e437d63e57ac290cd605876e5d1c2cd78a39ef4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1311/agentshield_0.2.1311_linux_amd64.tar.gz"
      sha256 "ed61966d081ffc3c54131396a83044958721c88ecad23710d55aaaa22e735af9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1311/agentshield_0.2.1311_linux_arm64.tar.gz"
      sha256 "4c6c0b3df810767ce8a726c7ed13e17631d227e177b345e76c00ebbe4932c265"
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
