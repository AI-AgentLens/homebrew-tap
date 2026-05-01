cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.845"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.845/agentshield_0.2.845_darwin_amd64.tar.gz"
      sha256 "8237d3915a83634148ce2980bd8aefafcf1deb113e12cdbb274182f995981fdb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.845/agentshield_0.2.845_darwin_arm64.tar.gz"
      sha256 "165a288dcf5f3da48020cda0fa759c6b1495e49df7a684094403f12f01e9e704"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.845/agentshield_0.2.845_linux_amd64.tar.gz"
      sha256 "8254c1cad0d0847b735cb5bddbfc9415f13daba4d1972a2a4518c854e943748e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.845/agentshield_0.2.845_linux_arm64.tar.gz"
      sha256 "4bc77e1046447b0b4f571e212ad64cb84531eeefe72a2fd2a879fb2633ea4630"
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
