cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.469"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.469/agentshield_0.2.469_darwin_amd64.tar.gz"
      sha256 "0ea656129fc10fa1b227dc3bbbb41cc57762bd150863604bae9c3fadbba475fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.469/agentshield_0.2.469_darwin_arm64.tar.gz"
      sha256 "56a33459073066a8ce490b006c186fd807f4d542910c772ca0263d6203b7b484"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.469/agentshield_0.2.469_linux_amd64.tar.gz"
      sha256 "a12f145d5349ae100c8608c429029c83bd3ab0215af4c2c4a92112498aa7c491"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.469/agentshield_0.2.469_linux_arm64.tar.gz"
      sha256 "1683de2a2934f86f749c6294d1c04f635d211081fed9ca5febb9d3fa8828b452"
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
