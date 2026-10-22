cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2501"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2501/agentshield_0.2.2501_darwin_amd64.tar.gz"
      sha256 "312d0ef9faecbfe0623d2f8fd60c214186a9943c252ba6270ff00a53cb03fd0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2501/agentshield_0.2.2501_darwin_arm64.tar.gz"
      sha256 "a9528d5d53c252856251ebb35c3ff6dfbab64e44a74c9124a0e2f1531cbf0de0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2501/agentshield_0.2.2501_linux_amd64.tar.gz"
      sha256 "388a40b90d9f208da11af97a0c60c4ef943e70a3cd5cb50df8f476e10b979022"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2501/agentshield_0.2.2501_linux_arm64.tar.gz"
      sha256 "c507ae8163f55e170f584279e221bcf593e2593e9b2034f7cc720c5930f2e6af"
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
