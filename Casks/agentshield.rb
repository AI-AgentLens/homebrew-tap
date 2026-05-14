cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.976"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.976/agentshield_0.2.976_darwin_amd64.tar.gz"
      sha256 "688003ce3548701022f0d905c8fcba5f75c306358be1ba517f1fa56538bb2cbb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.976/agentshield_0.2.976_darwin_arm64.tar.gz"
      sha256 "8491409dd23ad03f24a59d4c6fd908cf3f97f0b7f51d65dce206dc2772719641"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.976/agentshield_0.2.976_linux_amd64.tar.gz"
      sha256 "d5870935802a0c33b6a2e4a90ddffc049668ff1cb60dea876464a6b347369818"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.976/agentshield_0.2.976_linux_arm64.tar.gz"
      sha256 "fa064f8d7c6d42d89d462f68959d47ed2804f319af0009c33ab7f0a2cbc56dbb"
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
