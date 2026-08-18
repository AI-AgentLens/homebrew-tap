cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1900"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1900/agentshield_0.2.1900_darwin_amd64.tar.gz"
      sha256 "aacf91355dc354a4a25610872438d6272d3a0abceb51bfc1ecfd4577018bdb61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1900/agentshield_0.2.1900_darwin_arm64.tar.gz"
      sha256 "7aae8834cc12b10c9c55649525590608c079ee825d219f2f54da07b93d3eaa02"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1900/agentshield_0.2.1900_linux_amd64.tar.gz"
      sha256 "780c5890d046e74e1840d0f5ca959f12e9036bba60c6ecc56835365ab017738b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1900/agentshield_0.2.1900_linux_arm64.tar.gz"
      sha256 "d5118bfe11bc68364cccb4d6003bad72a632bc2ab44e8ca488d04b73e4d11f11"
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
