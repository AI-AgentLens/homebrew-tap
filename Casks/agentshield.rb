cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2429"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2429/agentshield_0.2.2429_darwin_amd64.tar.gz"
      sha256 "9c0c2e1cdcad47a8539643c4c631b3a1886f213e4807eedc2caa8a29735a712c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2429/agentshield_0.2.2429_darwin_arm64.tar.gz"
      sha256 "e8e5c1f74230f6ff457d0c27150051f9f489434e2fe18f6a59e271cfd03c0d14"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2429/agentshield_0.2.2429_linux_amd64.tar.gz"
      sha256 "d8f4e1934cbb5c275a29f9c8f117fa078b2d324c58bbfb42ef7d4ba9a8536f54"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2429/agentshield_0.2.2429_linux_arm64.tar.gz"
      sha256 "20fa45cc8fe843f689f57108f2a0cf22cc555359101164205975452e2b56d66e"
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
