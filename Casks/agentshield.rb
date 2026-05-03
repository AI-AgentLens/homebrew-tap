cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.867"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.867/agentshield_0.2.867_darwin_amd64.tar.gz"
      sha256 "9d8195dffdafcca6951728e3582589dc10ead7f04bcb237c047cecfc4b901ddf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.867/agentshield_0.2.867_darwin_arm64.tar.gz"
      sha256 "a76106b14e3cd224bbeaec3f29f5bd8cc29a504279d424282ebaef3aba5d1e06"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.867/agentshield_0.2.867_linux_amd64.tar.gz"
      sha256 "c8598cb5c62a8f14d5b5ee66237209280b2ab2b6b2d10f1ca203d25bebfc0ac8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.867/agentshield_0.2.867_linux_arm64.tar.gz"
      sha256 "cab72171a4e22384eed90d026318885651be3ef25b720b6b77db8bc53a0375f0"
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
