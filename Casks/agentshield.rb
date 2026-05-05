cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.886"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.886/agentshield_0.2.886_darwin_amd64.tar.gz"
      sha256 "1d96316f11f5f95265ef895912f290bbe0ccac438dfac08805267458e2d4268a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.886/agentshield_0.2.886_darwin_arm64.tar.gz"
      sha256 "d5788ac2031b2ab7f0e82411bb367514bdcb5878e53656e10da5144fd69bc78d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.886/agentshield_0.2.886_linux_amd64.tar.gz"
      sha256 "6d4ba81600e657eca605274c6ae52501712b12ce8c3d861d1d1cdb1ab0874f4f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.886/agentshield_0.2.886_linux_arm64.tar.gz"
      sha256 "afed9282a1f795fdc2156960fc7e112f11ec73fd04b40f0c52e22d6a13f96347"
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
