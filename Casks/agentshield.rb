cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2342"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2342/agentshield_0.2.2342_darwin_amd64.tar.gz"
      sha256 "54d76e29d579704090daa50b67498ff5c5ef347d66bcb325731628d3c589ca4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2342/agentshield_0.2.2342_darwin_arm64.tar.gz"
      sha256 "15f2885edb669f58fe399daaafbfb57e6c7be373879c9a8b1fa0c24109d624af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2342/agentshield_0.2.2342_linux_amd64.tar.gz"
      sha256 "65bec0caa2744ebd42763fc189f7dd5ec1d4f447003144f22eebbf0daafda923"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2342/agentshield_0.2.2342_linux_arm64.tar.gz"
      sha256 "d6b4540c79a95adc60cb97f404bcaebb7f4f39154af9e3f88f8e3ce4baee6d4f"
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
