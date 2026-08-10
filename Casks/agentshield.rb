cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1810"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1810/agentshield_0.2.1810_darwin_amd64.tar.gz"
      sha256 "4c218e92d75caef5874a6a3d5b1f5f7c6ad347ddb7b43f2b92bef9f70d1e771f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1810/agentshield_0.2.1810_darwin_arm64.tar.gz"
      sha256 "de8f0fc446d66991cdb913e458d1bdbfab09a8604f72aa60c91a3ba77e927204"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1810/agentshield_0.2.1810_linux_amd64.tar.gz"
      sha256 "546d398eabc7abbceaa5827d60d1f84d03610f5637f4516ab2de1b3e20f15598"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1810/agentshield_0.2.1810_linux_arm64.tar.gz"
      sha256 "6d0dbefee6f17f053bd70cf20554ce1c6c4a7511ba80cbcc188cbc59d3c27d10"
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
