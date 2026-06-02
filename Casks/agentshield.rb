cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1188"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1188/agentshield_0.2.1188_darwin_amd64.tar.gz"
      sha256 "031b515b67e7af908ee6e7dc3f4b989e91d3fea5a00861d0b347020ddc3d2278"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1188/agentshield_0.2.1188_darwin_arm64.tar.gz"
      sha256 "bb2bcc1e26ad0c21183c3a32cdfa85c3360cb5ec43e988d774fe5cb30c785fdb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1188/agentshield_0.2.1188_linux_amd64.tar.gz"
      sha256 "c445c01fcd750b7f86ddf18164ece1856b36ba52c7fd523c08b167f337e33347"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1188/agentshield_0.2.1188_linux_arm64.tar.gz"
      sha256 "6a39ffb7a6dfac4bb874939f006a3f44319133d2b6222e31b63467b0b158f3cc"
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
