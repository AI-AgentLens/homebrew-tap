cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.215"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.215/agentshield_0.2.215_darwin_amd64.tar.gz"
      sha256 "0d78162ca385cc08599b2eae134b206f001791a8704089b6a098b380780719c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.215/agentshield_0.2.215_darwin_arm64.tar.gz"
      sha256 "7df853c435f537655fa0a19a8b15af3df10c006599b93a75859fe76ff481b9eb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.215/agentshield_0.2.215_linux_amd64.tar.gz"
      sha256 "de1f9fc078616c8501a72434595af4eb5b3e32339cefe74e84b6314bee56cab8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.215/agentshield_0.2.215_linux_arm64.tar.gz"
      sha256 "09571e438d0dec3e2aae0567c439ef6ce18452f221a9fea3ff482418bd57ebff"
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
