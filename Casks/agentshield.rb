cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1387"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1387/agentshield_0.2.1387_darwin_amd64.tar.gz"
      sha256 "0bdb7cf65066b17ca1c8ab67a16fc3ddb122313c96be35a9b943d660f61230d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1387/agentshield_0.2.1387_darwin_arm64.tar.gz"
      sha256 "4967771896e9ebf15a07115395ac51e346624beb573653943d04200b6cdfe640"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1387/agentshield_0.2.1387_linux_amd64.tar.gz"
      sha256 "3838c9c52d278c4488ff065f804bc34de32c99516042b38626a3c1ad8c61ccff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1387/agentshield_0.2.1387_linux_arm64.tar.gz"
      sha256 "eccdd075d18ea233c75dabac5cc5c6e0b1780ed4d74b56626c50a0dca899b94b"
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
