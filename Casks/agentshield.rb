cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2230"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2230/agentshield_0.2.2230_darwin_amd64.tar.gz"
      sha256 "44825954d6f965cee96f664421d877fc07149c7fbfab0f21fc3390b733e410f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2230/agentshield_0.2.2230_darwin_arm64.tar.gz"
      sha256 "8e371e74cc04caac2d6ae68cd6fe385588f169c55467c9fae9d6ee14bc5f4e5b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2230/agentshield_0.2.2230_linux_amd64.tar.gz"
      sha256 "3303a64d51f58b11faa242a16a72705aac4a951252b3613b042288b094d61324"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2230/agentshield_0.2.2230_linux_arm64.tar.gz"
      sha256 "b8037274ee8f57aa9210ef361d00caaad2fa544a58617bfa053a0af068cc0cdb"
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
