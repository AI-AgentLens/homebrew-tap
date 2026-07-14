cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1641"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1641/agentshield_0.2.1641_darwin_amd64.tar.gz"
      sha256 "0acf2f2c6b310775e7c6dd889a476018392251ebfa4e3743af05d911652240d0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1641/agentshield_0.2.1641_darwin_arm64.tar.gz"
      sha256 "f74f13dd838c62247f90fb5d816d11fe40a08efec1e7c4c7abbeea4c29241830"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1641/agentshield_0.2.1641_linux_amd64.tar.gz"
      sha256 "b0faeea1994755169dc1536fb60598bfe5d9bb73720fec8bc48799a1c6a767f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1641/agentshield_0.2.1641_linux_arm64.tar.gz"
      sha256 "da21c08d69d2f9c1db258cb8febdc22f548805943a92aafc4b1c0c179f35846f"
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
