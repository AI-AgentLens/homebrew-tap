cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1291"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1291/agentshield_0.2.1291_darwin_amd64.tar.gz"
      sha256 "b9d942f2709cb203acd1118e3e47be099de208ad0af1fc05a8293c9f00f71e89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1291/agentshield_0.2.1291_darwin_arm64.tar.gz"
      sha256 "0f8f0ddb52c913c9e998b234960dd32b9d4d55b65c3c3be22bca849e67b286af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1291/agentshield_0.2.1291_linux_amd64.tar.gz"
      sha256 "9856f7463add741c3e0d1c898a786de7e00ae14e5602a56cc4c2b97cb55d6d51"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1291/agentshield_0.2.1291_linux_arm64.tar.gz"
      sha256 "49056bc98077b80d22b7bd9e1cf9ce5d0574d650f069a9757542823ceaaf84d0"
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
