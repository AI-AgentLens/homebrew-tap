cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.884"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.884/agentshield_0.2.884_darwin_amd64.tar.gz"
      sha256 "f836167a6699eeb91defd8ad350d8c7b2c0880f527adef2c081b4e90e9026e98"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.884/agentshield_0.2.884_darwin_arm64.tar.gz"
      sha256 "db8917538676cd8b0f652e67f9da8968473de0e311901c8fee0dcec2acfb91f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.884/agentshield_0.2.884_linux_amd64.tar.gz"
      sha256 "e9f2f7e5efc98126a8e7129d9883e5f214b2d8fad3b6a418bc23999d5b9ef42b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.884/agentshield_0.2.884_linux_arm64.tar.gz"
      sha256 "3a81499d1bac5eb15b6a87743b6f10429c709d5bbdccdb524c7894aeb4a91a72"
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
