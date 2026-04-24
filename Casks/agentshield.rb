cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.715"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.715/agentshield_0.2.715_darwin_amd64.tar.gz"
      sha256 "0c45cbd1e8f1272d349a5340b6c7a35fe94c4e3a300dc39d791f328fa6caea88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.715/agentshield_0.2.715_darwin_arm64.tar.gz"
      sha256 "ac723e4e63010116a473d4c4c2c300b32171c948c29080965de1035dec5d8ac4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.715/agentshield_0.2.715_linux_amd64.tar.gz"
      sha256 "440c90a7d33b06532e302cf7c12250e9bbd9f14d3317ee211377d1418b874d8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.715/agentshield_0.2.715_linux_arm64.tar.gz"
      sha256 "9c03e8b4ce268f6643cec2c9369b1f305b023d1ac5447c55497fb4dd5c8a29b7"
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
