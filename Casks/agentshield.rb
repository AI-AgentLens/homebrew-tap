cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1289"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1289/agentshield_0.2.1289_darwin_amd64.tar.gz"
      sha256 "b69ce03a687382b10c5d88f0f4c57847c3c6bfc7e0887259c9dc295971148ee3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1289/agentshield_0.2.1289_darwin_arm64.tar.gz"
      sha256 "44540ed22e105ea39b1d7366a61e7af4d65b91419780ae8c988cc7509f76723d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1289/agentshield_0.2.1289_linux_amd64.tar.gz"
      sha256 "23e4093ad595a33a22021c525edff9f0c7127f244be38edaee912e44b5a10af0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1289/agentshield_0.2.1289_linux_arm64.tar.gz"
      sha256 "07b225caeb45e51384ab5d8b68d7e3011c411d3ff88f4caa58605d4cdb27b9a3"
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
