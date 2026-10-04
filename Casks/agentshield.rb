cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2338"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2338/agentshield_0.2.2338_darwin_amd64.tar.gz"
      sha256 "afcd3d508b7baf061d8c083e8f28f5dfe49b4a937d57b57fa0688f2639bbdf27"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2338/agentshield_0.2.2338_darwin_arm64.tar.gz"
      sha256 "224fd17895fee6d0cd10100f66e010d42561c620aa0a49e1f6744dc6cfaf6fed"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2338/agentshield_0.2.2338_linux_amd64.tar.gz"
      sha256 "87b25932bad0e69c96fdd7a8c22ad0612739a0c768d65350aedb7a1283a74254"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2338/agentshield_0.2.2338_linux_arm64.tar.gz"
      sha256 "a0f13eb2c6d53729438673869708935bd289b8d24c7f43b9a1adcad96b7bb825"
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
