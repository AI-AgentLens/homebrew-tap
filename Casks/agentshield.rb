cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.225"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.225/agentshield_0.2.225_darwin_amd64.tar.gz"
      sha256 "7862fb262a0dbb5cd3d60a6de7e962a4585ee88c788a0e25949c850e08a3c172"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.225/agentshield_0.2.225_darwin_arm64.tar.gz"
      sha256 "5b0e821d1b85162c6ed057fff383fd9587ce88c29a8b57e5045a0e73e1ebca08"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.225/agentshield_0.2.225_linux_amd64.tar.gz"
      sha256 "a9e19df9d682cdbae36e1774f1ea2efeed67d2ac0204e9f860f8af417b6ae41a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.225/agentshield_0.2.225_linux_arm64.tar.gz"
      sha256 "763c6dcf6a939d28b40eef3804021627adb5849c8860a590b6439d22d91046a3"
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
