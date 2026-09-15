cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2151"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2151/agentshield_0.2.2151_darwin_amd64.tar.gz"
      sha256 "e2f737550c0caccd6b75a4e5d150e2c75a9c504b0db40aaf4692386e5f46d476"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2151/agentshield_0.2.2151_darwin_arm64.tar.gz"
      sha256 "d57a47d5dcfcbe38164c6cbd8ba688243b610ea2f6c94c43dc7575ef9e5d6343"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2151/agentshield_0.2.2151_linux_amd64.tar.gz"
      sha256 "c8994c9a580a12b561cb15c925e011dfec6ed974095f93c86709dbb6430a8b88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2151/agentshield_0.2.2151_linux_arm64.tar.gz"
      sha256 "a4a05a84d75481e4678b5e40750121b90a9bf88299edcc4c2a074e332f9c2c90"
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
