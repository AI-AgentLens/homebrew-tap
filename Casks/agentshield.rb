cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.426"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.426/agentshield_0.2.426_darwin_amd64.tar.gz"
      sha256 "d97e37308d860d8576010d9c4fa52de8f81d349aac4945b342e2a75880febd47"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.426/agentshield_0.2.426_darwin_arm64.tar.gz"
      sha256 "d4f8a0dc7450755a2371c960a09b2d0e3d502f2e162c96a5022221647898d271"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.426/agentshield_0.2.426_linux_amd64.tar.gz"
      sha256 "1a90c0fa019003c5ca2457bdf23d429f057c1a8163a9de0ba1a3d16a159054a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.426/agentshield_0.2.426_linux_arm64.tar.gz"
      sha256 "8b5e53939031fb6c2fade02705e6efe1e5a3f0276942b25e703458f0feabb712"
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
