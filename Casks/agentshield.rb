cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.847"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.847/agentshield_0.2.847_darwin_amd64.tar.gz"
      sha256 "ce3b7f5cb3654f6631d68094369538c108308ad211e0c2ed00d2b23747f53fe0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.847/agentshield_0.2.847_darwin_arm64.tar.gz"
      sha256 "2de1240d68015adfdb2ac4f7ad5f3ff773e5a56ae5276714c9a4dcdcbcf330f7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.847/agentshield_0.2.847_linux_amd64.tar.gz"
      sha256 "a06e2c79dec834c3b65ac020b6cd2632d07997bce16d55d94c6fd42c4476e87f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.847/agentshield_0.2.847_linux_arm64.tar.gz"
      sha256 "c4d6270a29e91d66162105a91634be60888b7448de19392806856f9a6f9a831e"
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
