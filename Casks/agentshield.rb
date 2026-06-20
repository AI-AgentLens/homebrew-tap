cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1379"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1379/agentshield_0.2.1379_darwin_amd64.tar.gz"
      sha256 "c4fef48e331d550a2edf8ba31ddb6bc77e2d1dd2bd6f3b1cb92670fd89873c71"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1379/agentshield_0.2.1379_darwin_arm64.tar.gz"
      sha256 "2f72405c093c52cd3c1f3fd62ed71cf11f4d5aa0c5fa46af6ef92ecaefff36cd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1379/agentshield_0.2.1379_linux_amd64.tar.gz"
      sha256 "b7965645db53b2ceedd110ea9f0a3a17293f8a189ad802d97ad415af509c7781"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1379/agentshield_0.2.1379_linux_arm64.tar.gz"
      sha256 "0789100ead6bcc82a1c07c36eeede50dfbd0d599b2b57bcdd97018914f18bb82"
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
