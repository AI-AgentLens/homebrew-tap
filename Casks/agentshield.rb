cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2318"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2318/agentshield_0.2.2318_darwin_amd64.tar.gz"
      sha256 "d0764ffefec3dc87a504e71b933cfa56c0b901d9449965f997d7deaa4bcd7d41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2318/agentshield_0.2.2318_darwin_arm64.tar.gz"
      sha256 "13ece235f43e2d6f0774a1897ab4c3201ba831165686168f7d70493b32dc962a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2318/agentshield_0.2.2318_linux_amd64.tar.gz"
      sha256 "1c86a266d42ae336146e6fe665abc9c20ff7e2f1413e27541d3fff5c593515e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2318/agentshield_0.2.2318_linux_arm64.tar.gz"
      sha256 "e438b3319077f7fa4e42286452a0a1b8ad928433db17daf169d7ed816a2dbc21"
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
