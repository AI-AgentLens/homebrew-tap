cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1636"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1636/agentshield_0.2.1636_darwin_amd64.tar.gz"
      sha256 "c914b6d45091a03c7f5dd0873d39f58c3636de84367aa0241dacf368db8e1e9b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1636/agentshield_0.2.1636_darwin_arm64.tar.gz"
      sha256 "4eaf574a5ccace3681521d991ec3b82d1438ef104af5e0da3b07660a07aeaade"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1636/agentshield_0.2.1636_linux_amd64.tar.gz"
      sha256 "cc927c0c7e5d310044d0384b79f2af1b47247d5d63b6dc54ff469af53f55591a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1636/agentshield_0.2.1636_linux_arm64.tar.gz"
      sha256 "8ac271a0032110905767b413c615fd129e182e2bac9aa123195797d3948cad92"
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
