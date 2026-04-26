cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.738"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.738/agentshield_0.2.738_darwin_amd64.tar.gz"
      sha256 "8a343aa2b3dbc0e8053dedc2898748935d7fbb90a1afeab229b1dd82f195f8c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.738/agentshield_0.2.738_darwin_arm64.tar.gz"
      sha256 "cfd01c1e83c09e0e8a91d78a69f90e924dfedecf4696e093bd071812ab6dcaef"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.738/agentshield_0.2.738_linux_amd64.tar.gz"
      sha256 "ab48068cc194f1b2c7a032eadc46f8ad9194d36c08729e515e22ab2827c81984"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.738/agentshield_0.2.738_linux_arm64.tar.gz"
      sha256 "e50296051ac09833d913302f7de22d7f3f825252839661cd1fbec944fbc130ef"
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
