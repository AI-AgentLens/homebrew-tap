cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.982"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.982/agentshield_0.2.982_darwin_amd64.tar.gz"
      sha256 "9309d9bf8da958d5f2d84d84ac28e2f2c7b97971dbddaf2a19de0043075a43d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.982/agentshield_0.2.982_darwin_arm64.tar.gz"
      sha256 "450073b89b2cfafea02a58da84bb376f2aff8e63af4b2a9de6156d99a17e215b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.982/agentshield_0.2.982_linux_amd64.tar.gz"
      sha256 "7d52b5051ab7948649cb377c3ebca9bb1811fa23a006ac98460aa64e90f5c4f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.982/agentshield_0.2.982_linux_arm64.tar.gz"
      sha256 "762ed8d80c0cfc28d21ea6b654baee8163c8bbea2954b7f4f86903ae029d0db9"
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
