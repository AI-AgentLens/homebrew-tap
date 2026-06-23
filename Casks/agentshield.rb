cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1419"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1419/agentshield_0.2.1419_darwin_amd64.tar.gz"
      sha256 "cca25b508df586dc744252ae37ddc2ea1819b50020f5a45b7640741c7ba50964"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1419/agentshield_0.2.1419_darwin_arm64.tar.gz"
      sha256 "e6f146462340c7652a1cdc26246b08fb576c6d6acad9501a93831530d6769603"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1419/agentshield_0.2.1419_linux_amd64.tar.gz"
      sha256 "abe922691ebda5fcd8247b6b1a7b913c4ae257cf32f90053afaba60647ec1afe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1419/agentshield_0.2.1419_linux_arm64.tar.gz"
      sha256 "f1d73a649ccbbed3507df4c1e91780ad7906fef0a5dcaf31fa212a907b14d99b"
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
