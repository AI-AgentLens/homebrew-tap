cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1554"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1554/agentshield_0.2.1554_darwin_amd64.tar.gz"
      sha256 "d4269a6dfa8c697beb4e315446b4314f35face0d572a3987bc165ea1d33840f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1554/agentshield_0.2.1554_darwin_arm64.tar.gz"
      sha256 "35ddf1a25325fcf9c7a3090fa367ec137803ed32143058a04ffa1cef40465aa5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1554/agentshield_0.2.1554_linux_amd64.tar.gz"
      sha256 "404f341c5dca051ca593aa5976a1e90ae1f02fbd521e05b0a4d61c4d09f48a00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1554/agentshield_0.2.1554_linux_arm64.tar.gz"
      sha256 "44c9ead4e1cd6e01aec4aa5a4e46b7c3886febd22e837a4ee3b3b5e30bb4fcbb"
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
