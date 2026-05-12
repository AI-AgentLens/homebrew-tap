cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.960"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.960/agentshield_0.2.960_darwin_amd64.tar.gz"
      sha256 "17e468a1987e3dbae99b2f713c59188c696ccd932e94e27d7ae7e31af67b2913"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.960/agentshield_0.2.960_darwin_arm64.tar.gz"
      sha256 "06424a4232f62c52f03e44cc09175bd23d7a245077b51e46ef92d1837925383a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.960/agentshield_0.2.960_linux_amd64.tar.gz"
      sha256 "94ef7eb95002037b46232237e70b48b1e6f9e1917c696943dea35c07bd4d5ecd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.960/agentshield_0.2.960_linux_arm64.tar.gz"
      sha256 "a05b3d0c91b0496c5a057f6895d8f7d180ef0d34639eb0c472c2228105c6d2fa"
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
