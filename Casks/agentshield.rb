cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.504"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.504/agentshield_0.2.504_darwin_amd64.tar.gz"
      sha256 "43da74d8ee5f46b2899064db9d06a1a6da2860a2f50e7ac79ab04af18629db89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.504/agentshield_0.2.504_darwin_arm64.tar.gz"
      sha256 "1dc5d47c9ec7803693695aeb9680242144e6afb1e2ff084db9d99f9e48250120"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.504/agentshield_0.2.504_linux_amd64.tar.gz"
      sha256 "6caa30330baf647749261716d78dc82c880fe062b0ec6e288862e4e13a859f69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.504/agentshield_0.2.504_linux_arm64.tar.gz"
      sha256 "ad482898601627e4148792a35c6dd301253d0b8fcfdcf46b6e717e446bd87fa6"
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
