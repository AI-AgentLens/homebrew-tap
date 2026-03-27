cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.135"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.135/agentshield_0.2.135_darwin_amd64.tar.gz"
      sha256 "61845e9a9efba65201d55e94690146da44cd7b7d5b5ac4895093349c442750df"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.135/agentshield_0.2.135_darwin_arm64.tar.gz"
      sha256 "8b1d4454870aad86529916167f18effc4ea944b9218e4280fa0b608523229b5a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.135/agentshield_0.2.135_linux_amd64.tar.gz"
      sha256 "a26feb42b60843465a343c10757e9c808c814bddafa11ffb27e1dd03510819c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.135/agentshield_0.2.135_linux_arm64.tar.gz"
      sha256 "b4d5e28316df4135d4d768aa24ca24e7740892ff1c0e156ea6622ef5dbf84417"
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
