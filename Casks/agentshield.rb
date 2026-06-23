cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1415"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1415/agentshield_0.2.1415_darwin_amd64.tar.gz"
      sha256 "49b442fd7476ce639376a8890b3c69a653e4f78ccca0df1829bc65fcd90d3c9a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1415/agentshield_0.2.1415_darwin_arm64.tar.gz"
      sha256 "822b96f408582e2ba478588bdd21b7dbcc57064efe9f31f8a9624fc499b0aa40"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1415/agentshield_0.2.1415_linux_amd64.tar.gz"
      sha256 "e3e56b08559a98bf166138307abb4e6f465d5120be016f04875f0da0565c7913"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1415/agentshield_0.2.1415_linux_arm64.tar.gz"
      sha256 "da553de781a7da0c2a7fafa0f8f424384a9c446d8771ba7875cc19b0f63e7380"
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
