cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1410"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1410/agentshield_0.2.1410_darwin_amd64.tar.gz"
      sha256 "5105dddf0d622122c5b5aa4bbbb5be34ce7d252fd341757cc1147ea96191ea72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1410/agentshield_0.2.1410_darwin_arm64.tar.gz"
      sha256 "d4479dd15e6817bc1f1be79760d39825ef1697fc28469319a560acbd226412b0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1410/agentshield_0.2.1410_linux_amd64.tar.gz"
      sha256 "4cd697b50020dc86515b032047a67dd3b0a6dc0c3a2c3fa7b91b4538e0ff0a32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1410/agentshield_0.2.1410_linux_arm64.tar.gz"
      sha256 "22644f155e2c62abecb5e759cc79ddb4b303d7636e0ec221fbb1fd504a78420d"
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
