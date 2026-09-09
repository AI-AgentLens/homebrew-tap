cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2096"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2096/agentshield_0.2.2096_darwin_amd64.tar.gz"
      sha256 "c2c2e3a41e8473b55343a8576538b566befa44002755c9615f1a1318f3879cbd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2096/agentshield_0.2.2096_darwin_arm64.tar.gz"
      sha256 "7159c010f58c9c6f8c1105a8b9ae3641be64d97dd2bc2690a47688d92c8a47bb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2096/agentshield_0.2.2096_linux_amd64.tar.gz"
      sha256 "860665b07650048f650081f8832a3a2fbbaa389642817d3cda22249663f61cf4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2096/agentshield_0.2.2096_linux_arm64.tar.gz"
      sha256 "3a9f9ab5546aaecdab25fe59984da762b580218d246b7ea960eb53a23aa4e78e"
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
