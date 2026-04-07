cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.483"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.483/agentshield_0.2.483_darwin_amd64.tar.gz"
      sha256 "b9c392ff805dc4e7158cd059dcd26074861b39d9e8e4aebf80898839e8c235bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.483/agentshield_0.2.483_darwin_arm64.tar.gz"
      sha256 "49c20caae465e65d46454fe11cc38e3b4c62345359cea26a1dad16dbf8f34c59"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.483/agentshield_0.2.483_linux_amd64.tar.gz"
      sha256 "b214871814801c8d005f5b5337084e3a32c89cb43e08e2dbaae33f45fe0c6898"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.483/agentshield_0.2.483_linux_arm64.tar.gz"
      sha256 "ff0a087bf5ab191584d50d78b7404ad9bfcabb2fad2434156c237f9a6cc48c5e"
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
