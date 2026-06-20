cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1380"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1380/agentshield_0.2.1380_darwin_amd64.tar.gz"
      sha256 "f4db935ff1c883dbc3b27964e78989ecdf0f0e881961672fdcdcd33a59dc30d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1380/agentshield_0.2.1380_darwin_arm64.tar.gz"
      sha256 "8da9de112a0b102c27f094f6e380156e55c30be19adfaecae61662ff3946f4ad"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1380/agentshield_0.2.1380_linux_amd64.tar.gz"
      sha256 "bd5745078293fda5bfae5e4e82885bc5acce77c3bd4be30db1b6ec62b0b77879"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1380/agentshield_0.2.1380_linux_arm64.tar.gz"
      sha256 "ae4d63df8a3061d00a3173e5a5a753d610e66cadaceed861211ce8afd96f2c13"
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
