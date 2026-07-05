cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1556"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1556/agentshield_0.2.1556_darwin_amd64.tar.gz"
      sha256 "321e217fefa407e17b396d62cd188129b36078d6597969d998df02f1351074fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1556/agentshield_0.2.1556_darwin_arm64.tar.gz"
      sha256 "8a3b0b54a764be72490a6ad87f132e9d350f45aa67c4a1840b8210d94c7a938e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1556/agentshield_0.2.1556_linux_amd64.tar.gz"
      sha256 "266d2f712bab6ad47a2d5e5f1278c4846088a4095ac834c35937ec8a3425dff3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1556/agentshield_0.2.1556_linux_arm64.tar.gz"
      sha256 "21fff2c2713909fbb7e8c2f67ac076c4a3017909af7dbb3be9f2bb1954dca82c"
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
