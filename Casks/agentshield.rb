cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2486"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2486/agentshield_0.2.2486_darwin_amd64.tar.gz"
      sha256 "2cc5e1af7ea57db82a4fe601ac400945dc23b35693992d087bb91b98164a7a92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2486/agentshield_0.2.2486_darwin_arm64.tar.gz"
      sha256 "7797cb41f7de8869138e8c586b8d883d8456bec26d932361e3735bb4b16e5717"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2486/agentshield_0.2.2486_linux_amd64.tar.gz"
      sha256 "59a6c2f44926f222a987d24589fd52a978724b0962db4856c5a2db7b675c1625"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2486/agentshield_0.2.2486_linux_arm64.tar.gz"
      sha256 "7575b1a13de675202082389393754faca03818ebd01a1275d647d32f0096ed86"
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
