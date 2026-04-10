cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.522"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.522/agentshield_0.2.522_darwin_amd64.tar.gz"
      sha256 "d6bd200679c405ba2630c8911f1cfc7d1c76e01fde15ef618b588fd552d78acf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.522/agentshield_0.2.522_darwin_arm64.tar.gz"
      sha256 "57eb392398ee56223d5c8e6e8fb5c91560bb7b07362d9b72dbecf3cd7fc4587a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.522/agentshield_0.2.522_linux_amd64.tar.gz"
      sha256 "7fe2fae5a432ba7d6158ad4a6ac7188053373cd819fcec91e2dc37722ddddeef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.522/agentshield_0.2.522_linux_arm64.tar.gz"
      sha256 "bac76a59041fca3ad1889caeedd54419ad0fae4deadc93009b21db7186c2c9a5"
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
