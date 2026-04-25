cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.735"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.735/agentshield_0.2.735_darwin_amd64.tar.gz"
      sha256 "64ba65bf0459ee544cc84e6b9d4c0ff73e6012ecec169ca03263bc122c3fddd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.735/agentshield_0.2.735_darwin_arm64.tar.gz"
      sha256 "5f5d99fc1eb2a69c176be582b3b9af38090420e7d5b5c26adadd6e7af2e2ab97"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.735/agentshield_0.2.735_linux_amd64.tar.gz"
      sha256 "ef2ab9a8bb2d99353e006888ba748725e990e39cde9bea23dbaf585b03e4dec5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.735/agentshield_0.2.735_linux_arm64.tar.gz"
      sha256 "54a42dcfdd12b50798125ec84c6a1615cf9abfb41363c93f65f91f4f74b3d527"
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
