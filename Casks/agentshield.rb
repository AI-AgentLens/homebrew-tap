cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1026"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1026/agentshield_0.2.1026_darwin_amd64.tar.gz"
      sha256 "ae0bb560355eccd6ac706e52d647356f2608492e64993cce4141c0d4883033bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1026/agentshield_0.2.1026_darwin_arm64.tar.gz"
      sha256 "bf35d934a6d824516a04ea82881eb33fc27ca1c81cae2f882243c049668a3028"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1026/agentshield_0.2.1026_linux_amd64.tar.gz"
      sha256 "337048cee97a25f4eb63475493928f30be0fc9666c102e883df8e8bb9a820a9a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1026/agentshield_0.2.1026_linux_arm64.tar.gz"
      sha256 "da415089b6dee1dfe4a98710106d1582c87c35e152766eb92ff20e1998a0e2d6"
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
