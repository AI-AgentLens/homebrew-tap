cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2142"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2142/agentshield_0.2.2142_darwin_amd64.tar.gz"
      sha256 "0f4d61317da8a2852142b84012a300009c34c19e1771843b9cf3ad996fc2cb2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2142/agentshield_0.2.2142_darwin_arm64.tar.gz"
      sha256 "8caed5c41bd8ec1957e9b286d236be01e33069d9668c54c2d54f27797e48edea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2142/agentshield_0.2.2142_linux_amd64.tar.gz"
      sha256 "b84ce2c5cb81f6ca88cb3532b05afe432ebc12cb0aa2fb619fff4ada1c4bbf94"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2142/agentshield_0.2.2142_linux_arm64.tar.gz"
      sha256 "7aff8a6f839bf35f276e3ca70042c14e81f2771c5ed4957c2604bcc8aa89a8b8"
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
