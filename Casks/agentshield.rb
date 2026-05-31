cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1172"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1172/agentshield_0.2.1172_darwin_amd64.tar.gz"
      sha256 "d88d546face01d2b539191e2870475e02a9cd4681130ef246cec4462c6fe8a85"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1172/agentshield_0.2.1172_darwin_arm64.tar.gz"
      sha256 "3d4b6a7668dd8445ec0c0487f85c962d1b71dddd69330084022dc4b14c10b40c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1172/agentshield_0.2.1172_linux_amd64.tar.gz"
      sha256 "8a4dbd6668fdd1edf0bb2fef287d1c9dcb96a5fc743241da172b60a7fe246dce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1172/agentshield_0.2.1172_linux_arm64.tar.gz"
      sha256 "2d895b81676a1b960d03ca6faef89bcf69c79eb3075940ac29e221d86b5e1039"
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
