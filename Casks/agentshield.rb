cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1367"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1367/agentshield_0.2.1367_darwin_amd64.tar.gz"
      sha256 "69a4327f7ef3a98a1c4c3087579f131824b0c5082b040128e8212d7a82af5a08"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1367/agentshield_0.2.1367_darwin_arm64.tar.gz"
      sha256 "287137d304174305f6b759796310d5c8132f1db8bf3b218bf07707ec70fefd79"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1367/agentshield_0.2.1367_linux_amd64.tar.gz"
      sha256 "2b4b611016be016c8eedd26f724b7a4db33c99bf3c5dc19389aa591ee2d15b39"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1367/agentshield_0.2.1367_linux_arm64.tar.gz"
      sha256 "2b1df7bedd52cdc630531332b8ebb3d6d6dec5d1beb9975e5be8fcb82edd8b85"
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
