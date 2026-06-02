cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1195"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1195/agentshield_0.2.1195_darwin_amd64.tar.gz"
      sha256 "0239c02aa805b251c4dd8252f08938c08a5ed455a9380c5440f30bb98bbabb1c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1195/agentshield_0.2.1195_darwin_arm64.tar.gz"
      sha256 "bbfd2a0dcccb2b94fd05ec1eca76d5f33eea3511dd9468af87e2456523a377cd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1195/agentshield_0.2.1195_linux_amd64.tar.gz"
      sha256 "2aa2d92849a542b86ec396223b9583fa92ce8072cf14ca3fcd18ea681e9b72b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1195/agentshield_0.2.1195_linux_arm64.tar.gz"
      sha256 "61b73655184b5f9023832a22bc146e55548ec6d077736242625b86ec4edc7de0"
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
