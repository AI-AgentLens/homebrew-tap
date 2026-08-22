cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1924"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1924/agentshield_0.2.1924_darwin_amd64.tar.gz"
      sha256 "a73c3278e88796026c62a3ba257e03b7769a186a8b0464a91c5d019715f366ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1924/agentshield_0.2.1924_darwin_arm64.tar.gz"
      sha256 "cdca32a45aa986bac8083c89fe2d2e27c4487c9e63f960318165ec296084291e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1924/agentshield_0.2.1924_linux_amd64.tar.gz"
      sha256 "ed4937437f383bb0c09095fea91f11dc37d0e63a411410ba06b8a204d4a58ac4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1924/agentshield_0.2.1924_linux_arm64.tar.gz"
      sha256 "dd4830fbd209eb61c7c0e06f88edb8dba0ceca5ae0d863c5dda746400f7a75fe"
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
