cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.241"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.241/agentshield_0.2.241_darwin_amd64.tar.gz"
      sha256 "40bb2284d18664e19cddd10edf604b9205ab801d88d030b0f6c1581e0827de4f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.241/agentshield_0.2.241_darwin_arm64.tar.gz"
      sha256 "9485da5f789e3d6291e3138d38ae13d0141a604499838c84b592031c167727c7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.241/agentshield_0.2.241_linux_amd64.tar.gz"
      sha256 "3d3db79d721fa658ecc49a3ebb9be2c039356415363379d5ee1d0c18525e3153"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.241/agentshield_0.2.241_linux_arm64.tar.gz"
      sha256 "b6484130e08a856ad2dd7dd22bfaa6731212604e10e2a1e42536534a83c5f8c8"
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
