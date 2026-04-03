cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.359"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.359/agentshield_0.2.359_darwin_amd64.tar.gz"
      sha256 "1b0a5921893fcf910befe78b062a474aeadce274c7899e28c04cbc60aab46ba7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.359/agentshield_0.2.359_darwin_arm64.tar.gz"
      sha256 "6c636fc05623392821d20737bc5ae6f84062a2bcb5540f0bc1229935f6b53ef7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.359/agentshield_0.2.359_linux_amd64.tar.gz"
      sha256 "9dc2f29263e6b07bc63701a9f5beda5c44e983285f6d4f4e384717bcc85ec675"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.359/agentshield_0.2.359_linux_arm64.tar.gz"
      sha256 "130f1e8daaac696b6d76252a1d5c29f0a983cd608dc1ff830a7a568d90b262e9"
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
