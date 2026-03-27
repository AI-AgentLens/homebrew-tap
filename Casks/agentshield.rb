cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.120"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.120/agentshield_0.2.120_darwin_amd64.tar.gz"
      sha256 "638105b1abc5202767a7927c70dfb943b70a245275c8b6c3fba853e05091da07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.120/agentshield_0.2.120_darwin_arm64.tar.gz"
      sha256 "38f1cf40b6ee39ad85cb6a13919872672b71ec550988aa59f0cf62dc1c0d5b6e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.120/agentshield_0.2.120_linux_amd64.tar.gz"
      sha256 "2b0316a4acd956773bc0ef444d8687a25ec699330932dd2b5b01fcf23455c6b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.120/agentshield_0.2.120_linux_arm64.tar.gz"
      sha256 "30e0925f1b4d24c2a867e3b9ac8d4a85b7cb22e3d18aa9d83d79c61836da3a65"
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
