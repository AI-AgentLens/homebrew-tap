cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.451"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.451/agentshield_0.2.451_darwin_amd64.tar.gz"
      sha256 "9106620b34a6d48a0f14c1dc5c2b5777084c14ed2ca9e02b1fde57e7a31a235c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.451/agentshield_0.2.451_darwin_arm64.tar.gz"
      sha256 "7a5f9f27c09b3844d1f7ecc3bf15d821e9e8baa3a5af2f72d836eb7980e2a7b6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.451/agentshield_0.2.451_linux_amd64.tar.gz"
      sha256 "b725367de771851cfde4fde81c8cc1472b1067178f2aa65c115383c6d4290166"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.451/agentshield_0.2.451_linux_arm64.tar.gz"
      sha256 "b1e1918571b756d3ae0893dd0467535e8ce58a4328c338b6b9c46c62dd46a78a"
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
