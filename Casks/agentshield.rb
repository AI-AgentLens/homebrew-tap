cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.789"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.789/agentshield_0.2.789_darwin_amd64.tar.gz"
      sha256 "5067bfa772d72cb66d88876a3d4b8b7165210750192077e1e8c303436dd05868"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.789/agentshield_0.2.789_darwin_arm64.tar.gz"
      sha256 "e05c0fdba88513287bd6570b6fb017c1c90c6b1cfb438389cb858e4326cdaac6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.789/agentshield_0.2.789_linux_amd64.tar.gz"
      sha256 "baa31968cbc9910094d7747f8b130359a98836661f901b60e3ad1deff163902b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.789/agentshield_0.2.789_linux_arm64.tar.gz"
      sha256 "499f8b10ad56e22bcb1d702cb60f0bb9f5fef7d8581b13ca33104ed0dfd519c2"
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
