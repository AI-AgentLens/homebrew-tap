cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.176"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.176/agentshield_0.2.176_darwin_amd64.tar.gz"
      sha256 "9c88a7c0918725a1048d6bb6bba6fccb7768ebb2d17344f718eb34b4536cfec2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.176/agentshield_0.2.176_darwin_arm64.tar.gz"
      sha256 "13d3bb8ac65576d1a855b60a92cac3068a759754cf6e086bf5c60f9d504edec3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.176/agentshield_0.2.176_linux_amd64.tar.gz"
      sha256 "60e1d0f95abe8c0eace44af80d59130bc623008e98e8ca45a36756075814fcf4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.176/agentshield_0.2.176_linux_arm64.tar.gz"
      sha256 "cb6b47f8e5f23352f9a6b5c27bff3a59de02f76a8b6949e93ccbdb66604d40c7"
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
