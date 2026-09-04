cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2038"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2038/agentshield_0.2.2038_darwin_amd64.tar.gz"
      sha256 "dcb3a177458deda8a75f0d53cfc6cdc264f89461dfbd42bbd011f5b70063a97e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2038/agentshield_0.2.2038_darwin_arm64.tar.gz"
      sha256 "f59c1ed838d68e844d8102f73c0d6d535a6a6735295854719b89c2eaa13369fe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2038/agentshield_0.2.2038_linux_amd64.tar.gz"
      sha256 "a27566de50e2602cf48bf7ff9af0e93dbeab63a111eb3fa457bfcc350a0c935e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2038/agentshield_0.2.2038_linux_arm64.tar.gz"
      sha256 "d8205a43d88141a196dff5ec67ee139cf8b8fd3b8fc429c5273514ca7a3ec309"
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
