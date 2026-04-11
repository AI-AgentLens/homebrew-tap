cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.544"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.544/agentshield_0.2.544_darwin_amd64.tar.gz"
      sha256 "2971df91a693be6246d2f6045abac8e82a00032bbadb9245170219161f01e428"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.544/agentshield_0.2.544_darwin_arm64.tar.gz"
      sha256 "7ca2f50d755deece5d42c00441fc8b7701d1945cccdc1fd2fc8273c7913774dc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.544/agentshield_0.2.544_linux_amd64.tar.gz"
      sha256 "c19c501f1c51b1dc08f6a6cdc86c6184121b03e77d781c981a48812a020ffa2b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.544/agentshield_0.2.544_linux_arm64.tar.gz"
      sha256 "92bd5b0f411233329f6847ce174a68defe963b5b8ee837cccc9bda9db29d8182"
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
