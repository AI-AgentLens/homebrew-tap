cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.565"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.565/agentshield_0.2.565_darwin_amd64.tar.gz"
      sha256 "13f640a464920e93f3ac6e4a88fe490c11f1b4f8631ee34aaf657641a9ead20e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.565/agentshield_0.2.565_darwin_arm64.tar.gz"
      sha256 "bbaff0d118a2b09ce39a484d5291b7dccb3a2149304c6b8eff0414e09286b9f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.565/agentshield_0.2.565_linux_amd64.tar.gz"
      sha256 "347e0274c194ce2fac5ae57f76376ef2dacfbb3c413b6045311b028f3d6f11e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.565/agentshield_0.2.565_linux_arm64.tar.gz"
      sha256 "b83462238e41cc733892595c443c93205119b992a073e69c857c14671b3a545a"
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
