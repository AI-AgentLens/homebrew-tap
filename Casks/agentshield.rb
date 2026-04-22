cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.681"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.681/agentshield_0.2.681_darwin_amd64.tar.gz"
      sha256 "6d0cef6becdd8c5657155ccccc78f52984ea6ed4fc4d6ecdde1654940f6f3eaf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.681/agentshield_0.2.681_darwin_arm64.tar.gz"
      sha256 "404c73a3ce96e4cdd7d7f5fecc013e12e0c8333b26914711c201c45237d68102"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.681/agentshield_0.2.681_linux_amd64.tar.gz"
      sha256 "eefd8a6ab18f7ac25ddf94dd280708864b93045b434dc503bdd68d2bbdc9611f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.681/agentshield_0.2.681_linux_arm64.tar.gz"
      sha256 "7896eac544a1cd51e5fd545cdfd7c20dd7a1014add7b5e3d2c95ac42274073d8"
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
