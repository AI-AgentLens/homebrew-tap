cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1914"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1914/agentshield_0.2.1914_darwin_amd64.tar.gz"
      sha256 "c611e604fa78e34f698bdf6704ff61838f87b33b6a925f3c0fbd0bf586233e9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1914/agentshield_0.2.1914_darwin_arm64.tar.gz"
      sha256 "9a793708afd2a03178f49e32dc26fa7c772bcdbcd276f58018c5d5c883270e05"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1914/agentshield_0.2.1914_linux_amd64.tar.gz"
      sha256 "27a67db867585f6dad652b57ebe81deb52a546f8315c169486be6e3fd259a434"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1914/agentshield_0.2.1914_linux_arm64.tar.gz"
      sha256 "926059bebe265dfe31adca7ba6065e52e62d9746460e87558f20dc7a9f4a457f"
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
