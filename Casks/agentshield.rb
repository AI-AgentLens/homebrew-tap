cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2520"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2520/agentshield_0.2.2520_darwin_amd64.tar.gz"
      sha256 "0558cafa47a9d3cbadd38dddf7684660fd43dd7063d8f8fb3ae9b4493b447533"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2520/agentshield_0.2.2520_darwin_arm64.tar.gz"
      sha256 "61e27d3504b55461a6c71c0a7cf7c3f495ddb603cd3264f94ef463a32c292a9d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2520/agentshield_0.2.2520_linux_amd64.tar.gz"
      sha256 "d604cedc3f9022f478abe6e5d02600c4d3279007f729ac3d2c1787eb33428a18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2520/agentshield_0.2.2520_linux_arm64.tar.gz"
      sha256 "8f822137ca5fcb411df7245be078a3c1705a0fae99f922776b2b191002f39564"
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
