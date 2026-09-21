cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2212"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2212/agentshield_0.2.2212_darwin_amd64.tar.gz"
      sha256 "cbd1d489c140b71dc315b6cc56948c56ad17f22eecb099498ec1f9422e12666f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2212/agentshield_0.2.2212_darwin_arm64.tar.gz"
      sha256 "171bb2ee58cbfa6a574e789aa7a4ef488900ef923a1ec36082962a7137156954"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2212/agentshield_0.2.2212_linux_amd64.tar.gz"
      sha256 "f66d1bf7817abb31d5694768640d8d31167a832f08772b341e90e6691c15a5a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2212/agentshield_0.2.2212_linux_arm64.tar.gz"
      sha256 "2c53061f18c963c83950363d5f68027280bffe4ffcd8a11108eed9e4bca51cb0"
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
