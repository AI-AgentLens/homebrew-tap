cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1368"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1368/agentshield_0.2.1368_darwin_amd64.tar.gz"
      sha256 "451ed9756f2739733f9446e2235b56066c1c9b701bdaca45b34f47a8281c085a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1368/agentshield_0.2.1368_darwin_arm64.tar.gz"
      sha256 "ad2cc6b485e07d96244ba827ff133f776dc2bbfcf5c89b65b08b7e4616e7dfa7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1368/agentshield_0.2.1368_linux_amd64.tar.gz"
      sha256 "742c9a22d506bb42853b2ab44262134cedbc87cc07808f80aa2086095a2d7537"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1368/agentshield_0.2.1368_linux_arm64.tar.gz"
      sha256 "9b5bdc91298d104f4179fe622747efebc5c8b99f1dace864fde0feae0ddaa14e"
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
