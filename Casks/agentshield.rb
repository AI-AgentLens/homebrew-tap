cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.304"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.304/agentshield_0.2.304_darwin_amd64.tar.gz"
      sha256 "27d31947543eb024f79557b599888c52bc774b165348600b6050a11e5e452691"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.304/agentshield_0.2.304_darwin_arm64.tar.gz"
      sha256 "4d9853aad8298a12c30d67a67a0d3ae100f0106031c34f2e4e08cc30a6166b0d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.304/agentshield_0.2.304_linux_amd64.tar.gz"
      sha256 "2f47f164dc1694cea42ec62ba026b2b4bc09368d703d0f48b83fa47e3bea164f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.304/agentshield_0.2.304_linux_arm64.tar.gz"
      sha256 "738565f9386fcb698793acd8bfe0308f20423e10b2f7ba116f70e986bc35d55f"
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
