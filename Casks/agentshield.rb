cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2241"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2241/agentshield_0.2.2241_darwin_amd64.tar.gz"
      sha256 "88b9fc100f473fd9da8f8c0d6f773a352c0fec69fc04ebeb6ca90b64c0b0261c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2241/agentshield_0.2.2241_darwin_arm64.tar.gz"
      sha256 "9f7259b1da15563963042dc9a2b19147f37ae65d14b06a1d99717193c2c97b59"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2241/agentshield_0.2.2241_linux_amd64.tar.gz"
      sha256 "90d33973ba3c1cfdc9b76a6ccbf82ec102448046a074c864e6b863a4c074aaaf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2241/agentshield_0.2.2241_linux_arm64.tar.gz"
      sha256 "931d4106cb01187f9b72d3ca4b46e17d048a188766457e529bd38aa417404eef"
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
