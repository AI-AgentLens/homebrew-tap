cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.694"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.694/agentshield_0.2.694_darwin_amd64.tar.gz"
      sha256 "1158db06442de1480fcfbf8d43e0d106e7eeb9c0a4e6865c9c40becc57a59d32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.694/agentshield_0.2.694_darwin_arm64.tar.gz"
      sha256 "4ac8e02e7cdb5af6f7a0d28aaf16246ef64fc60e3888a757753b56c50b7a571d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.694/agentshield_0.2.694_linux_amd64.tar.gz"
      sha256 "92bbb915fe0607614d5ea501dacb5a8968b40189578bcfc3d64db2de3cc5a150"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.694/agentshield_0.2.694_linux_arm64.tar.gz"
      sha256 "edb391d3481af60cbb0499bba25dd280631c1038c92aaaa9db069d406fd3a118"
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
