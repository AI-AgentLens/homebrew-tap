cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.826"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.826/agentshield_0.2.826_darwin_amd64.tar.gz"
      sha256 "cd54e4be49aa312637714e2c69abae0deef40c07ddcc4def477c40fec090be5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.826/agentshield_0.2.826_darwin_arm64.tar.gz"
      sha256 "941fe95af3bb0bb623b9129a2ee0492a8941dc471a91f21fdca7e251e1aa7c78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.826/agentshield_0.2.826_linux_amd64.tar.gz"
      sha256 "79b2c73cfa425039f7023ebd437fec5827e546c5a154b4f63fd5caafd2d0a3c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.826/agentshield_0.2.826_linux_arm64.tar.gz"
      sha256 "0d6ce09553cf1e069c519ef5fa650c83b6c3b4b3dc951e6c221e8a4563c07243"
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
