cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.280"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.280/agentshield_0.2.280_darwin_amd64.tar.gz"
      sha256 "5494f9468373c670ff2e28a029f264c5dbc6b3eccad5d5effa3cbdfc894041f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.280/agentshield_0.2.280_darwin_arm64.tar.gz"
      sha256 "709cd306b1588af244c0317b1173527129af3cb66a085e0a9228018a1859d480"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.280/agentshield_0.2.280_linux_amd64.tar.gz"
      sha256 "bfc341868db687751f7218aac4cbfaa871cdedd6eb6ae073bbc3388d95a9ffc7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.280/agentshield_0.2.280_linux_arm64.tar.gz"
      sha256 "883ac361521680397a87e7d2e3eadc706aed99fbe0b04118e2c40c763b800be4"
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
