cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2136"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2136/agentshield_0.2.2136_darwin_amd64.tar.gz"
      sha256 "d302c918f524353aae310acf2a15772f9b19757a79d334e08ccb6e938108d361"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2136/agentshield_0.2.2136_darwin_arm64.tar.gz"
      sha256 "47c4eca482f9c51106b7978c63ccf87ef6d7570716df1293a7f3fed02f726466"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2136/agentshield_0.2.2136_linux_amd64.tar.gz"
      sha256 "db87c5d4a7138d215aa6ce086d2e26e7c5ff737f98c440d4cccc6125e4348928"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2136/agentshield_0.2.2136_linux_arm64.tar.gz"
      sha256 "fbbf52579b7950ab8a38968d7c37d9e5644fcc8d5125f429e5cdb766cfdea28f"
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
