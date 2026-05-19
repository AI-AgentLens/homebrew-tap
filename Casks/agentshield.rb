cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1030"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1030/agentshield_0.2.1030_darwin_amd64.tar.gz"
      sha256 "eac2a0288492b1319a0f0acc8dc7c18b88e3e491d5cfb7a7bf4fa22f891d0d44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1030/agentshield_0.2.1030_darwin_arm64.tar.gz"
      sha256 "872c00c8477af577f0e862f2a7f74a4197394f2c9498b71e76860d273ed9aa81"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1030/agentshield_0.2.1030_linux_amd64.tar.gz"
      sha256 "9e70873368346ccc3f51e11189d4777174259c9cdac9c346bf17a11d1ffbc081"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1030/agentshield_0.2.1030_linux_arm64.tar.gz"
      sha256 "6645d3d826843cd3f901ee4d9a13c7daf2a55744a7e22a7a8470db329ed454f8"
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
