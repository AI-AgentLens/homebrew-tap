cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.625"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.625/agentshield_0.2.625_darwin_amd64.tar.gz"
      sha256 "e2766e1af52a5b6c266b424c7545ebe86bb863b90678efa07579779924749fc0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.625/agentshield_0.2.625_darwin_arm64.tar.gz"
      sha256 "74001aba4c1855904a4fd8f7d60f530fb17b21ce1a74fe2067626f328241b9eb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.625/agentshield_0.2.625_linux_amd64.tar.gz"
      sha256 "790a524a7a992a37752c01fde7b3cd7e60f07cc9a173fa63e736f41628f0c9fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.625/agentshield_0.2.625_linux_arm64.tar.gz"
      sha256 "9f211fc260d7ef864cf3f6b824ab736405bd1fbaf46e8c916852677fd1bc839e"
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
