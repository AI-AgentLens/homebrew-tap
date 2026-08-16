cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1875"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1875/agentshield_0.2.1875_darwin_amd64.tar.gz"
      sha256 "56e433be391ef265822ea57d71dd9dd284a6152fd1e02bd39b97f49ee54203bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1875/agentshield_0.2.1875_darwin_arm64.tar.gz"
      sha256 "acf6d6931cd379c1ec2c30c2610b85558ed1d55d4c1c50f1c8ffb78f1d03adc5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1875/agentshield_0.2.1875_linux_amd64.tar.gz"
      sha256 "8a607d8dd839a357b478cbbb4e4611fb83133b51a738180b1fcf479f61600978"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1875/agentshield_0.2.1875_linux_arm64.tar.gz"
      sha256 "66222c41e217c6baad9d176fa56cde22d0875c585ed4297c96d84abd7f0feca3"
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
