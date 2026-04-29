cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.816"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.816/agentshield_0.2.816_darwin_amd64.tar.gz"
      sha256 "295229e3cec8edc1632f2e07e6ea71c6a8e0f7a54f8bef2784b85d535766896e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.816/agentshield_0.2.816_darwin_arm64.tar.gz"
      sha256 "2d749c95e675240cce3f1882ab67cb114402eccafb5e565e2dea9fd808e686a4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.816/agentshield_0.2.816_linux_amd64.tar.gz"
      sha256 "1001200433491dc40c933144a4ef7c0179240e29141c2d5ecebacbf488e5e209"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.816/agentshield_0.2.816_linux_arm64.tar.gz"
      sha256 "552376087817d358a8fa51e4c60f5fd0539ae3c78653837049c8a5a5c389551c"
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
