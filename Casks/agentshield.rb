cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.446"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.446/agentshield_0.2.446_darwin_amd64.tar.gz"
      sha256 "bdbebfcb13271d786a7c8325f18e202791bc9565fb17aa0b8d3949e27a9943a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.446/agentshield_0.2.446_darwin_arm64.tar.gz"
      sha256 "5e8c3ccd748c10382edcc12a681c33e0ce54f1f7eb0108be0ffa19e0a80f5fdd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.446/agentshield_0.2.446_linux_amd64.tar.gz"
      sha256 "b2bf04603925f947854cb0a3212465348989a5f0528077793ea1af0e3b45c008"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.446/agentshield_0.2.446_linux_arm64.tar.gz"
      sha256 "56b2fef6db874c31c095143dc609ff61bab0b53d19ce36712172ec11397f6d3c"
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
