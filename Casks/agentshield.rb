cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1098"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1098/agentshield_0.2.1098_darwin_amd64.tar.gz"
      sha256 "0ea372ddfed011413dcc92cc174db0cf2a98a9552d7dcd5ec9689a2eeb8a624b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1098/agentshield_0.2.1098_darwin_arm64.tar.gz"
      sha256 "d765ebe9ce877b072ebf925d8c0ee87efbd14868c8dd819557d75e6e099e26fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1098/agentshield_0.2.1098_linux_amd64.tar.gz"
      sha256 "3f6deccec80531ee5ae5e4f087b3fdcd5aeaec674d51fd2044503fc9fa29954e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1098/agentshield_0.2.1098_linux_arm64.tar.gz"
      sha256 "226401ae872a2b42185ff92c237baec84466c41a6454abf02a933efc73bf45b0"
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
