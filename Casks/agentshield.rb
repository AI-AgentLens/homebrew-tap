cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2320"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2320/agentshield_0.2.2320_darwin_amd64.tar.gz"
      sha256 "4fd629e3d0527d135ffeab190b45db2619f11cd5173bd0ac1eae0cc89f61eb29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2320/agentshield_0.2.2320_darwin_arm64.tar.gz"
      sha256 "ab00d465233190eecc772d1db1e2217552a6631cc3871da3cbc346d952ade9a7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2320/agentshield_0.2.2320_linux_amd64.tar.gz"
      sha256 "59b03d9cebcbf28534a9e3e71b8f2c1a5c32669fc43de70339d511c1dac85359"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2320/agentshield_0.2.2320_linux_arm64.tar.gz"
      sha256 "bbd362dac9dd0ac04df683e090c459779c89d37c1b79bf4b16ab8002fff7f484"
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
