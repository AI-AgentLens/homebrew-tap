cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1780"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1780/agentshield_0.2.1780_darwin_amd64.tar.gz"
      sha256 "a71fc7fb7da8d66758e4a4e5db0cabbf6149ef745b5c8838b9105d4fb9152b01"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1780/agentshield_0.2.1780_darwin_arm64.tar.gz"
      sha256 "bf8f760e9e3d40b92ebd9af2522503949eb06e6e30901482be60760780bf446d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1780/agentshield_0.2.1780_linux_amd64.tar.gz"
      sha256 "3b39a1786cc8e9054dacf3d0185476edd0da097337d9b69d2fa84eca105c7167"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1780/agentshield_0.2.1780_linux_arm64.tar.gz"
      sha256 "c7d6893a3111332fd0960e07a6a47629679ac95114f1b2112851ce102d81fe64"
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
