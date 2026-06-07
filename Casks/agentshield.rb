cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1232"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1232/agentshield_0.2.1232_darwin_amd64.tar.gz"
      sha256 "d690769ec8a1a63c2fa1249ff6c2aab33413b646e139cf9c9fcbefcb636ddf8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1232/agentshield_0.2.1232_darwin_arm64.tar.gz"
      sha256 "b3b16cdea3794cdbbb5972947aabfd119ca5543bba695666eab76751e794977f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1232/agentshield_0.2.1232_linux_amd64.tar.gz"
      sha256 "e82b9d544f86c847e40563f886c9c0745bcfe8a517d9bf5d56376559ea565b5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1232/agentshield_0.2.1232_linux_arm64.tar.gz"
      sha256 "0b09bac8d4516b3150a8f747eff6b62eab34e758422523b9b7461966b6cee26c"
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
