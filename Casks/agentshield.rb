cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2463"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2463/agentshield_0.2.2463_darwin_amd64.tar.gz"
      sha256 "95410b699c81826029b6b081e0a091308b7b39209242d4c482ea64c6adf53c34"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2463/agentshield_0.2.2463_darwin_arm64.tar.gz"
      sha256 "9f2d482cf83cd36fa7ac017a4729667f981969ec0a33bba81bdc06f207db6576"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2463/agentshield_0.2.2463_linux_amd64.tar.gz"
      sha256 "ff517a4a9dad6811a97db4d579e0b8bd03359b14753e5d88f23feaafe56cd776"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2463/agentshield_0.2.2463_linux_arm64.tar.gz"
      sha256 "235173f594bb74b3c360fca3ac5875cb9e752bbf473af61dff2f7d3992a9f870"
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
