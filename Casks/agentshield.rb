cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.781"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.781/agentshield_0.2.781_darwin_amd64.tar.gz"
      sha256 "1ee747cbf5a79e14074872aef1ce90d8eeb020ef45abba7c52c2447cef825fbd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.781/agentshield_0.2.781_darwin_arm64.tar.gz"
      sha256 "c41f0d2007d498235736abb7d9d93b8fb393a0b934e2eded87b8b33eb2a7d77c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.781/agentshield_0.2.781_linux_amd64.tar.gz"
      sha256 "1445fa37771f3df70d8485bd21c180ae1304c25f5ed34ab5424d00ac065ddd6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.781/agentshield_0.2.781_linux_arm64.tar.gz"
      sha256 "c2a3c8438af26cf5f75c29a429dca84f9eb9a6b5d3aea5af7e8518754cf449b1"
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
