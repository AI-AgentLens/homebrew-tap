cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2439"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2439/agentshield_0.2.2439_darwin_amd64.tar.gz"
      sha256 "3984a4229f620e90b171924f4eac50a1135b1d6b4d79cfbe1efdcea0238a1309"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2439/agentshield_0.2.2439_darwin_arm64.tar.gz"
      sha256 "291f619ce3d3bbd934fe6a5728a2c0209c5f68d7d5db93b568c4537b09dcd7bd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2439/agentshield_0.2.2439_linux_amd64.tar.gz"
      sha256 "781cda03fe3273d7ba3d59e1b7f6a705882817dd8783c3f1c597989e37b5ba19"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2439/agentshield_0.2.2439_linux_arm64.tar.gz"
      sha256 "ec2c33c3350726798d0be2c2c183a51ddcbde78522bc06ffefcd68e8cbdd1d43"
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
