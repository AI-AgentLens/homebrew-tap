cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1126"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1126/agentshield_0.2.1126_darwin_amd64.tar.gz"
      sha256 "d19d02207b363dd699476b7600ed46672bcf272f8f46247087c0c159c5392a3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1126/agentshield_0.2.1126_darwin_arm64.tar.gz"
      sha256 "6cce91e97fb066fc896717d01ca5a7c3f4caff6faca12c4667a852b86590998d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1126/agentshield_0.2.1126_linux_amd64.tar.gz"
      sha256 "15be63ec251a42f5633a8c55f3bc77e71ca7af89913c639edde541541d7fe7cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1126/agentshield_0.2.1126_linux_arm64.tar.gz"
      sha256 "0f0d84eb40cbdbf9fd9c2214a0b8b30ae10810908a6d45ef8bd629e25bdb52c0"
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
