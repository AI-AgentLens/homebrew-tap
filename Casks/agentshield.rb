cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.614"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.614/agentshield_0.2.614_darwin_amd64.tar.gz"
      sha256 "884a213a336d7fbd36e00814488c1e7bdb0a5a9e501d5cffb989165a3433074c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.614/agentshield_0.2.614_darwin_arm64.tar.gz"
      sha256 "5dc874891a367ac748a73e32e6ae81e136222e4de0f4116515e90520003c4a4c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.614/agentshield_0.2.614_linux_amd64.tar.gz"
      sha256 "9c701b392ba647d27ef6b0e2a865c9a73a6011725bf4cc71288aa5365454ce4c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.614/agentshield_0.2.614_linux_arm64.tar.gz"
      sha256 "9948623331d00d643d3b635047895366e56f05800a11fb3753ffbb49a04fc274"
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
