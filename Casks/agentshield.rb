cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2415"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2415/agentshield_0.2.2415_darwin_amd64.tar.gz"
      sha256 "052e234b74f37e278a3751a9d5595c933b31f55e4e10d2c7af11b6a201bce78a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2415/agentshield_0.2.2415_darwin_arm64.tar.gz"
      sha256 "84d00978fa28b92c279a455e8cb902ffe6da7fa2fcebe6bd5fb045be954e7e11"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2415/agentshield_0.2.2415_linux_amd64.tar.gz"
      sha256 "655d7e9bf8b1190d43e3eab2a964184e399a5b3f9d53a1d5c93ce282d77a0ea3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2415/agentshield_0.2.2415_linux_arm64.tar.gz"
      sha256 "703afb8d9de1b44058f26083e8dc51d47c6c2b76f01c37f4ae78dafe4eec5f1d"
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
