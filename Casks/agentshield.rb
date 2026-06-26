cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1456"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1456/agentshield_0.2.1456_darwin_amd64.tar.gz"
      sha256 "fcf5ec4e0008163bace425393c37b56ac02893e88279c06ee983d98334d5cff4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1456/agentshield_0.2.1456_darwin_arm64.tar.gz"
      sha256 "a7e64356e11b1f62609dd051d74d04438d7a2ab56f41a09c84447a9fa380cc78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1456/agentshield_0.2.1456_linux_amd64.tar.gz"
      sha256 "f6f9414c61234cc48bde3b57478391e457dd13583121fc9bf8cb57a7d4b5fdf4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1456/agentshield_0.2.1456_linux_arm64.tar.gz"
      sha256 "9f97223d3e48a53e6d4dfa6364389a5f5cf95603d205ef29c148d5a6e1e1899f"
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
