cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1332"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1332/agentshield_0.2.1332_darwin_amd64.tar.gz"
      sha256 "f4c7b6e4e1bddc35a9ef7f7c73985178aae6d514f170ebe25bcdcbf9a873fd65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1332/agentshield_0.2.1332_darwin_arm64.tar.gz"
      sha256 "d625d9a4e0cd301ef38d7abe4b833583f0dcf5339189e49e5165c22ae4aa4dc1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1332/agentshield_0.2.1332_linux_amd64.tar.gz"
      sha256 "7b6895803587505840623a181bdbed145af619fdc155d973ee9a0fed047af270"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1332/agentshield_0.2.1332_linux_arm64.tar.gz"
      sha256 "4fb4ec8d0fb2b61e11e498ca0817afb08b65309aecb6cfa63f65a7bd022d24b8"
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
