cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2105"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2105/agentshield_0.2.2105_darwin_amd64.tar.gz"
      sha256 "95d02abb595bf89b14f912188174c3634f4ce1b1347bf01665bc17174d3c8b4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2105/agentshield_0.2.2105_darwin_arm64.tar.gz"
      sha256 "14a14bbacebdadc8ca74758e7b494ef9173415491bf6023518aaed01b6885e13"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2105/agentshield_0.2.2105_linux_amd64.tar.gz"
      sha256 "ea78e12e63ebf1449ba4e1cb425304a4779deaf58d4fadb799e6465b0cab3d17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2105/agentshield_0.2.2105_linux_arm64.tar.gz"
      sha256 "2c38c7c82fb3e79546a1336ee7b0e6218acaab58769e43e8a3e01452038ea113"
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
