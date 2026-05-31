cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1165"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1165/agentshield_0.2.1165_darwin_amd64.tar.gz"
      sha256 "287ac2fa99aa621505b7cd156c04ff0fa02dae8b7ead566a030f9e271371f740"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1165/agentshield_0.2.1165_darwin_arm64.tar.gz"
      sha256 "c287960ef5f1b44aba688080f24663537f2dd0d1e2c5ba762e6c11f32d062888"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1165/agentshield_0.2.1165_linux_amd64.tar.gz"
      sha256 "db15bd15f941cb2bbd8d0d2d9bf8ba907a4b35d33b99e0cdd78c6824f3db5c89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1165/agentshield_0.2.1165_linux_arm64.tar.gz"
      sha256 "882f38a446260e0c7676fddab8b326449d1957292b7357496eb562e5ac03dbbe"
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
