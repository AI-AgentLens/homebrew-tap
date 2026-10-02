cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2311"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2311/agentshield_0.2.2311_darwin_amd64.tar.gz"
      sha256 "a6932904385d3e3698fbaa7435fbc670442d51230e3c6b4897e20083ad4b177c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2311/agentshield_0.2.2311_darwin_arm64.tar.gz"
      sha256 "504ea77e05e78b904c605f99c8934acd55ea26401a3732095aa5a69511a61a10"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2311/agentshield_0.2.2311_linux_amd64.tar.gz"
      sha256 "c165d21fd464c7b9789786fcfc0a1b33b26e069c8e3ccb7273fd4298cfbca503"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2311/agentshield_0.2.2311_linux_arm64.tar.gz"
      sha256 "85de97fec2ac93e60d9cc032a5ea52170a2f643e7f0115235706e8ee2faefcd0"
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
