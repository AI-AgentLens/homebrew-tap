cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.700"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.700/agentshield_0.2.700_darwin_amd64.tar.gz"
      sha256 "91a8cfedf3ff7a74d8b54a84b16b315b9b2e2fb037537d926693b2c4219a4161"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.700/agentshield_0.2.700_darwin_arm64.tar.gz"
      sha256 "600d7f0f1f53d882805571491ee7b46b10f1e2451f5a1b382b92e4c4521d6e4c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.700/agentshield_0.2.700_linux_amd64.tar.gz"
      sha256 "df915d6df9c4775b6763dbd84788c0afa0ac24f80749dda5d55b6377d263bbe3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.700/agentshield_0.2.700_linux_arm64.tar.gz"
      sha256 "56b8cb8358a0697381aa8b7329adc2c96f7bb4d31e909cba233e7573dced70bb"
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
