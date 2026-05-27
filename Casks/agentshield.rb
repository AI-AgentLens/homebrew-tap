cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1125"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1125/agentshield_0.2.1125_darwin_amd64.tar.gz"
      sha256 "0ffe72ff8d80f3e4479da77768a3c7a00b46fafa8f57a2771c96adfd4763eed2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1125/agentshield_0.2.1125_darwin_arm64.tar.gz"
      sha256 "f8662cced122f56dbac4edd03387a6b77a7ae002c9a671e98888bbf69d42fa58"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1125/agentshield_0.2.1125_linux_amd64.tar.gz"
      sha256 "e113c03f1ce285720d89b7ad44473795ef81f0759c5d7e8b8c8d3baf5bc10f5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1125/agentshield_0.2.1125_linux_arm64.tar.gz"
      sha256 "9280a155abad3c0f5da0e8c0e4fce457b54fa13db4c293686428ea42fc10adf3"
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
