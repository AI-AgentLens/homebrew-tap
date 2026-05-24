cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1109"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1109/agentshield_0.2.1109_darwin_amd64.tar.gz"
      sha256 "8ad8b9f878a4f5029d8902dbed037ded80553259c3aba385d0cc12c870033fca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1109/agentshield_0.2.1109_darwin_arm64.tar.gz"
      sha256 "b66eae1e4d0067ffc55caa11cef1beb71c6049e611b05b45b04e0bb5f1b352d5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1109/agentshield_0.2.1109_linux_amd64.tar.gz"
      sha256 "028ba9d976304d7cd6a2438e953d9900817fe8aaef48e73f50c15fff1c8677f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1109/agentshield_0.2.1109_linux_arm64.tar.gz"
      sha256 "aed6c22794119a103e46348b000eebe150dbbaa29fb75331af4d954caef03909"
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
