cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1632"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1632/agentshield_0.2.1632_darwin_amd64.tar.gz"
      sha256 "ad39b703a0074d379765e8ae917e63afc640eb950916cf95f2a36ba46d65f4f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1632/agentshield_0.2.1632_darwin_arm64.tar.gz"
      sha256 "f0f676c2920b520b939cd053cd7f5bb40c58fc641117f68349cccb7ff5db75cb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1632/agentshield_0.2.1632_linux_amd64.tar.gz"
      sha256 "ae81cc30ef1c556b6a07f19b7c8eea7da1f28fa399650e0b9d6872a883261d02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1632/agentshield_0.2.1632_linux_arm64.tar.gz"
      sha256 "35bed94be49555f476f5dddf42a1bb223a374262f2205cb790667e15aa8348b4"
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
