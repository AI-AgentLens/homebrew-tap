cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1118"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1118/agentshield_0.2.1118_darwin_amd64.tar.gz"
      sha256 "ac5dc7ab998437a7dc3c7adf251b3106abe2e7ce40aafe710f7c0ba5cc376180"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1118/agentshield_0.2.1118_darwin_arm64.tar.gz"
      sha256 "c1fb2aa3eb89159af79e849b917f2853b12b0b49a25d1d7067667967044ffbde"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1118/agentshield_0.2.1118_linux_amd64.tar.gz"
      sha256 "1f01f0d3802892f388fe0bcc550113ca6fb354ffae8b3618d2940f7222bb041f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1118/agentshield_0.2.1118_linux_arm64.tar.gz"
      sha256 "33fd39460350263822f2777a0c9c9b4559bbf68635aa585df305d639a7b2675d"
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
