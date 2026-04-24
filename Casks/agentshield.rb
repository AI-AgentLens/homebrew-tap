cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.709"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.709/agentshield_0.2.709_darwin_amd64.tar.gz"
      sha256 "21b4968de084f46f5e8fa5faa04a174d661014735ca3eff27f841c89835de029"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.709/agentshield_0.2.709_darwin_arm64.tar.gz"
      sha256 "950a048040347a8c67b757e6f63bbaf3899d659d86e52603bf250f74d3005813"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.709/agentshield_0.2.709_linux_amd64.tar.gz"
      sha256 "a4197e8e921dab9d6135130d5f72cc8b5fc3379c411e7a9b955acdb15d4a577a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.709/agentshield_0.2.709_linux_arm64.tar.gz"
      sha256 "525159d17014f31dd63ed66a150808e73923c2068e6afd9fd9b75345acf33931"
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
