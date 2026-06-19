cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1370"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1370/agentshield_0.2.1370_darwin_amd64.tar.gz"
      sha256 "085940d49817e461f75398655cac1f5a71409e06e6625a5ef2f0c7aad67159cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1370/agentshield_0.2.1370_darwin_arm64.tar.gz"
      sha256 "b25ddb9c4e1154a53c294effc6ad5d8023060fe6c615765e6df6e8c5c3722d70"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1370/agentshield_0.2.1370_linux_amd64.tar.gz"
      sha256 "8aa4404248ae3d01793d2beea24ade4fd4e7c373ee96beaf26e29ba33e0c05ac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1370/agentshield_0.2.1370_linux_arm64.tar.gz"
      sha256 "4952a19d21ab663b751dc3e1170eb0ff8c86d704b0436b42c84550b89e52bbb0"
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
