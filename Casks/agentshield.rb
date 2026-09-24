cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2246"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2246/agentshield_0.2.2246_darwin_amd64.tar.gz"
      sha256 "491bd7f0bbf723341f73ddee531a1fed3d37763510cee3a157cdf4da6080a99f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2246/agentshield_0.2.2246_darwin_arm64.tar.gz"
      sha256 "c84e7ba6e4356f5a9b4a5583d3f5199898e36079a0dfca7fbda8ec0fca2865f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2246/agentshield_0.2.2246_linux_amd64.tar.gz"
      sha256 "a9e4d9441bee55e1bd6fdd2dd2466db2c3fd51158d70e2aba59211453dd43f4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2246/agentshield_0.2.2246_linux_arm64.tar.gz"
      sha256 "716616c60315906d8763b46692e828d8191e5efedc1f7f1ecffa44b9964fdf48"
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
