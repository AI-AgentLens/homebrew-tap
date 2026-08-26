cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1956"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1956/agentshield_0.2.1956_darwin_amd64.tar.gz"
      sha256 "b255e2f7f0237492940944804671c0d8f26bc4042f1533426352ff1e7a8b4684"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1956/agentshield_0.2.1956_darwin_arm64.tar.gz"
      sha256 "32ec30f1c56f71f444f88b3c08c19c5b73b39844b1d18bae7fc7818a41bf766b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1956/agentshield_0.2.1956_linux_amd64.tar.gz"
      sha256 "ff41ebf31228e47766bde7b6fa5025a2abc29b4d4339ce721dbf23b8d665a5aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1956/agentshield_0.2.1956_linux_arm64.tar.gz"
      sha256 "ef488faa7ee1053892fec475195c9148bf0bf2c7921fe0cee7026c45559145b1"
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
