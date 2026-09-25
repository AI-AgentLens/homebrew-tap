cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2259"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2259/agentshield_0.2.2259_darwin_amd64.tar.gz"
      sha256 "70b209ca461e8a728898845770bee0362c9ec426efe714980d3bdbc18e9e378f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2259/agentshield_0.2.2259_darwin_arm64.tar.gz"
      sha256 "6fbffb94c458881a6ff75f0763cff0017caf8e433d3325a2dc49a86a796d60c1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2259/agentshield_0.2.2259_linux_amd64.tar.gz"
      sha256 "b729a393114bde32a89a7f5a3384e549acad6f53b0911a11481536a3f6039ad3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2259/agentshield_0.2.2259_linux_arm64.tar.gz"
      sha256 "764458fe02f6cfaa944b7ed3feb739c4f43340b7abff5c7d3b7d17c29744cd9b"
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
