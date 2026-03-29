cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.183"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.183/agentshield_0.2.183_darwin_amd64.tar.gz"
      sha256 "475a629a06f24e6f399fc24e432a3645bf0aab1a6faf49e936ddff7e21019492"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.183/agentshield_0.2.183_darwin_arm64.tar.gz"
      sha256 "bb2344c6e370fd350a6371ce3b39e53fe0832fa40165b189e16ba8ed786908ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.183/agentshield_0.2.183_linux_amd64.tar.gz"
      sha256 "ace3178f4e833fbdabad1f8dc35b663f47dc7619c5919a011a179a8830d24f56"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.183/agentshield_0.2.183_linux_arm64.tar.gz"
      sha256 "5cfbda79f277c6f95b60ea677292a48d8fad5237f7d27970262da14fc23c52be"
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
