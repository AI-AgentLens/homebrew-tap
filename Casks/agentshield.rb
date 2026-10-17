cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2455"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2455/agentshield_0.2.2455_darwin_amd64.tar.gz"
      sha256 "569516fcb0c8d408210f6d2a64ccf0b6b659a01331626abfff4ccf2771f97551"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2455/agentshield_0.2.2455_darwin_arm64.tar.gz"
      sha256 "9772ecf66fb935284190bb1c30dc334bcf5a1577df539db593dcda768d549326"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2455/agentshield_0.2.2455_linux_amd64.tar.gz"
      sha256 "b5096776181a5212f9dcb236a7a530c98c147ef3a6c4fb0d385527cb4896fcf6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2455/agentshield_0.2.2455_linux_arm64.tar.gz"
      sha256 "459b24383297c6806685e654fe96e44cecc21bf3938acfab99b9dbcbc5cd9271"
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
