cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1751"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1751/agentshield_0.2.1751_darwin_amd64.tar.gz"
      sha256 "5a10ea6343cd8571f122a9de8ee32710641c5a3314c52be7ad5a5c3d9d23defe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1751/agentshield_0.2.1751_darwin_arm64.tar.gz"
      sha256 "0ac1b1f075add4a36bc61630f7148c9cd4e6df6a623d2ba47880fd2db105aac6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1751/agentshield_0.2.1751_linux_amd64.tar.gz"
      sha256 "da72d8109931ca31bd10ca535d3495da0e5cb682c31ad886f0161bd9162db4f0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1751/agentshield_0.2.1751_linux_arm64.tar.gz"
      sha256 "3f154bc23cb8cbf4579aa51ed0b8e03443e4c2e9b504319a3208b3c74bc4f672"
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
