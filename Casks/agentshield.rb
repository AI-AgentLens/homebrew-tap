cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1196"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1196/agentshield_0.2.1196_darwin_amd64.tar.gz"
      sha256 "9f176129f2585d629b3168640574d4921351530e1e857324f276547cd640a451"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1196/agentshield_0.2.1196_darwin_arm64.tar.gz"
      sha256 "7a12f03230894ff7d0a87679d4adc0349918af0bc674a1d2c7f1f69223abed57"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1196/agentshield_0.2.1196_linux_amd64.tar.gz"
      sha256 "77e539c3746f918a8e611490293f25bfd52c6ac3fb0b894fe5e9aebab3b60c9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1196/agentshield_0.2.1196_linux_arm64.tar.gz"
      sha256 "29bd71dd2cf48987d956c40323b030b7074aa619f4e566d5081b95d5e2a758e3"
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
