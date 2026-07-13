cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1634"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1634/agentshield_0.2.1634_darwin_amd64.tar.gz"
      sha256 "4be026ae76b427db03f4a214df55335c35f75b68e510a138b265e7b8a119d204"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1634/agentshield_0.2.1634_darwin_arm64.tar.gz"
      sha256 "dbf6ab97eda7026f218ccc40bd830967483a2e8e830dfc52ed585861b91d1b3b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1634/agentshield_0.2.1634_linux_amd64.tar.gz"
      sha256 "7b7cfbcbc992eb7e6bfb909d90e675804a2f9f38f9d842bcde73b9bf9753f877"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1634/agentshield_0.2.1634_linux_arm64.tar.gz"
      sha256 "9c794ac4022d55aef36259a0a70f62efef09edd081c45111e7964ccbb869c3a9"
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
