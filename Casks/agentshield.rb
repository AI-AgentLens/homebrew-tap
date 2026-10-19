cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2467"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2467/agentshield_0.2.2467_darwin_amd64.tar.gz"
      sha256 "706a5847106ed7c2188a07dc821d22c4a8489b68b20030e6f8b5cb9ed3d14ac7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2467/agentshield_0.2.2467_darwin_arm64.tar.gz"
      sha256 "862c289a1d57fd266c53f07854fd3ccb4adc3035281d2a64215e3479758b223a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2467/agentshield_0.2.2467_linux_amd64.tar.gz"
      sha256 "b97d52dcbbdb9d399c55ac0c667e29da2aab00866e72d9dee80d614e40d9880d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2467/agentshield_0.2.2467_linux_arm64.tar.gz"
      sha256 "b8f10c276d8bca6dbf7d02365270c946d95bb6f24e896c21a2c5ace1b391a59d"
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
