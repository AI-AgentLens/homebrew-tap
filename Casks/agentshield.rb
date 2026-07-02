cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1532"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1532/agentshield_0.2.1532_darwin_amd64.tar.gz"
      sha256 "e35327a84652b4028fe7a3e354c610876eea07f8d9d1ebeda55bbb6b58496ecb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1532/agentshield_0.2.1532_darwin_arm64.tar.gz"
      sha256 "bcfe8f498085cb0ac766bd2f2e3b59f9c1dadafd1edb46323cad14101b7afe9c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1532/agentshield_0.2.1532_linux_amd64.tar.gz"
      sha256 "e78da3d75ba109bda7272a776ac0eaa4f0e88c51fee6dcd1def90e04a1f6cd34"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1532/agentshield_0.2.1532_linux_arm64.tar.gz"
      sha256 "a6916033af0c7899121a9a9a4c381b00735741555edfa2cbd5c80ad59b397414"
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
