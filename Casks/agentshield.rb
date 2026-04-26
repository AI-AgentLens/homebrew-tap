cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.757"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.757/agentshield_0.2.757_darwin_amd64.tar.gz"
      sha256 "cff20aada9ca6167697e5108b09fe6b164fda8c2d6ba5d86d159524109682c8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.757/agentshield_0.2.757_darwin_arm64.tar.gz"
      sha256 "cb3720286f147d2b1ee06797bb1740669153870342ccb8dd96bdb12fd3969161"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.757/agentshield_0.2.757_linux_amd64.tar.gz"
      sha256 "e8e82355f703e1bb9c531f773c44b4dfc297165aadd7f76f03278eec75d133aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.757/agentshield_0.2.757_linux_arm64.tar.gz"
      sha256 "6fd7df29e0f636272447b69aa9a519e05b3bdd3426e24711a73eb4ef41899bba"
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
