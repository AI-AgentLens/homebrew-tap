cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1116"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1116/agentshield_0.2.1116_darwin_amd64.tar.gz"
      sha256 "b625cf8ecedfa7014f51a17692035750e797d5c2f569fd67f729050627912a3d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1116/agentshield_0.2.1116_darwin_arm64.tar.gz"
      sha256 "68b584f8f0ff011db6df703d937b1c7a413100fd700898538391c7e3a97e29b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1116/agentshield_0.2.1116_linux_amd64.tar.gz"
      sha256 "08d2dc4c81c530d9191a5fa503d0987360995ca87bd70cc7c02a33537bdee282"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1116/agentshield_0.2.1116_linux_arm64.tar.gz"
      sha256 "8d3146910d99c942d8b9c4bab51194242d7fc33f026d64262a72f1876ad3d23d"
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
