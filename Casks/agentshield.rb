cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1139"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1139/agentshield_0.2.1139_darwin_amd64.tar.gz"
      sha256 "946648208bd121556db72d6ebfc126d9ccde8b53b51163b4888e96a49bbc7f39"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1139/agentshield_0.2.1139_darwin_arm64.tar.gz"
      sha256 "bebc964c2143d570563cb025e152cd3ad946ca774f4d967b0d2df647168c31b3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1139/agentshield_0.2.1139_linux_amd64.tar.gz"
      sha256 "635564fe348991d4ce62dab6cb7f4ba6d5d6fb949bde4a26d997d160b8a2655a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1139/agentshield_0.2.1139_linux_arm64.tar.gz"
      sha256 "004ca7d477a9ef894b4b279c8b4a8477a5313fcdc3a38fe4e13b603395262512"
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
