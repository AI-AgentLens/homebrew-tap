cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2165"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2165/agentshield_0.2.2165_darwin_amd64.tar.gz"
      sha256 "ad1244a4dd01dc7650706b2be56735139d612ca6bf8f2f86bec5687d7877ed29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2165/agentshield_0.2.2165_darwin_arm64.tar.gz"
      sha256 "57172510225e04ae0b0bfa32a995c62c618c4d86f25d59ea6aa960bbd4bff567"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2165/agentshield_0.2.2165_linux_amd64.tar.gz"
      sha256 "ec9323d9af329958757c4e85bf51baa0efd52a0e5727499cdeecad92028a5a6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2165/agentshield_0.2.2165_linux_arm64.tar.gz"
      sha256 "585553bbc7dead94d6581dd41ad1d5d09255055e6619637fdcab6f85edcbb8f5"
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
