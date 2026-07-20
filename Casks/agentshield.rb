cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1695"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1695/agentshield_0.2.1695_darwin_amd64.tar.gz"
      sha256 "1c18ae03d2f8694c5cb7a338ea686b9ba499a47e8bab7c0bb399670401f4b463"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1695/agentshield_0.2.1695_darwin_arm64.tar.gz"
      sha256 "3b323b1b6de6c3bb4c706b89fd309f5f19c74a37c907db0af83fed463f970835"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1695/agentshield_0.2.1695_linux_amd64.tar.gz"
      sha256 "63dc0e3b746242ead70b77f727bf93747dc111f06f3afce7fa8a2620d53c7a74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1695/agentshield_0.2.1695_linux_arm64.tar.gz"
      sha256 "32d2613d2d99ed8e93fc1445006516aeadf13aa066f046f0f64073dfaa8d0161"
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
