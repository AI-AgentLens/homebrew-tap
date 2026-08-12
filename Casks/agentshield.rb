cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1837"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1837/agentshield_0.2.1837_darwin_amd64.tar.gz"
      sha256 "4d6f4dba2486c6040e24b957c944841013d983ced725a9d4000619ae20994d6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1837/agentshield_0.2.1837_darwin_arm64.tar.gz"
      sha256 "f9ddce4d814e83a2ac42788a8146f58b56c6ab778e2387cbcd4f7515f03d7962"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1837/agentshield_0.2.1837_linux_amd64.tar.gz"
      sha256 "f42bb5613bd815bcc6ba5140880a6200fb7b165832da6000f0bcc1fb271ac3b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1837/agentshield_0.2.1837_linux_arm64.tar.gz"
      sha256 "f431c20fa11e6f5d98fdbf1e5e49e468bbb22861c4fa9be58130412312d22f06"
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
