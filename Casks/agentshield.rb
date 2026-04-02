cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.336"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.336/agentshield_0.2.336_darwin_amd64.tar.gz"
      sha256 "9a415a08d56161d9f8291931b4ac5cc382e1fde4f4c7d5d97d13a9714be6e20c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.336/agentshield_0.2.336_darwin_arm64.tar.gz"
      sha256 "bb09a5dd8fa47c4199dd3a868da6d17b7f84163f081f18ba2ebdafbf3222391d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.336/agentshield_0.2.336_linux_amd64.tar.gz"
      sha256 "80d6f6513fc4ab12dfeb7d8fb4cdf63368ad18f8303202cf38c119420771b541"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.336/agentshield_0.2.336_linux_arm64.tar.gz"
      sha256 "3148cfa41937198414b71e432b311abab1f2c9766c83e35d3ae6074643b48e1c"
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
