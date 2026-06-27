cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1466"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1466/agentshield_0.2.1466_darwin_amd64.tar.gz"
      sha256 "b99d5ff66605bc76adb7395c0bbc39e6acf466d0dead56f212cfc8a8e09bd57f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1466/agentshield_0.2.1466_darwin_arm64.tar.gz"
      sha256 "6652fde4394605cd98bf6ac7f4cdfc39f9b45a11f4e090f5635ca690269260ac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1466/agentshield_0.2.1466_linux_amd64.tar.gz"
      sha256 "16b3133cf5d4520be832f5a80a4c3bcfb1c6bbd5b6d7b4ecb0660c68e61efe12"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1466/agentshield_0.2.1466_linux_arm64.tar.gz"
      sha256 "5f0c87add4ab3b3a6e8cca9910773f1eb64c7f7b63326a026c31c0c6e18a6e84"
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
