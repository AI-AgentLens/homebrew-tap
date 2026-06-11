cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1282"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1282/agentshield_0.2.1282_darwin_amd64.tar.gz"
      sha256 "01dcb610b906138f7feceaf77f34d6511782fd6f7ff918c183f275cbefd3d8f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1282/agentshield_0.2.1282_darwin_arm64.tar.gz"
      sha256 "ca4a8750554b6dd62fc2a3166da3a0433246fb742de9612479596938031fbddb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1282/agentshield_0.2.1282_linux_amd64.tar.gz"
      sha256 "01400598032ea16a7ece5a6c49d426cc383adbfd28d6ca03ad74f834e9e66a29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1282/agentshield_0.2.1282_linux_arm64.tar.gz"
      sha256 "9dec263317561a3301ec4183a21fc3c4cbb8988ede5260ff146e5d616ae74eb6"
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
