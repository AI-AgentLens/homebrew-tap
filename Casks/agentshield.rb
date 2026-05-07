cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.893"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.893/agentshield_0.2.893_darwin_amd64.tar.gz"
      sha256 "cab1c9ed47c11a5c82697c8a7f59830863923ec80a6a91e4f997d634822a331e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.893/agentshield_0.2.893_darwin_arm64.tar.gz"
      sha256 "e333c95ee75d043a22d0b569cbb6b9f16aa6e9279c9ec37e898e3a1489b092cc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.893/agentshield_0.2.893_linux_amd64.tar.gz"
      sha256 "e17ec0fb3667159448e42f32a115b6f77df8e0b5d8b1bb30e05e3edc8a6487bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.893/agentshield_0.2.893_linux_arm64.tar.gz"
      sha256 "f8fdacee3ca195f6417fbe7128e4ccb7e0d6bf7d4ccf001a478efcbb582a9703"
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
