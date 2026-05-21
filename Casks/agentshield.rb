cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1057"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1057/agentshield_0.2.1057_darwin_amd64.tar.gz"
      sha256 "38d1c26309368b5bff4607a65498ff211538f92efa53d74d2d9ec04fa9eb53ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1057/agentshield_0.2.1057_darwin_arm64.tar.gz"
      sha256 "26a91e9ac16b088b10dac1778e7fc194ad50e98db71bd1f1692afdf0bc5ae1ef"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1057/agentshield_0.2.1057_linux_amd64.tar.gz"
      sha256 "67e13eac9871df9966d5c06e55c4a3dab641cf3d440663afa6389cc974dc361c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1057/agentshield_0.2.1057_linux_arm64.tar.gz"
      sha256 "8dcf8d7fa7770b6698aa4ef97b1edd43c9f982c3fda88928ad6bc881759bb484"
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
