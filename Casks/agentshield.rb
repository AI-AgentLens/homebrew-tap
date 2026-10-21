cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2490"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2490/agentshield_0.2.2490_darwin_amd64.tar.gz"
      sha256 "c8c1490a4fcc8f14a85189cf452a269da0286b8b9287db42aded3fd538862e69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2490/agentshield_0.2.2490_darwin_arm64.tar.gz"
      sha256 "3b204683c13998fec26a133d415c9f7803c8b23d17ec4ae1911d6f67c975103b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2490/agentshield_0.2.2490_linux_amd64.tar.gz"
      sha256 "aae50e175fa77d770486171ec4793aa79baee47d433ec6fcac4a0f556192257d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2490/agentshield_0.2.2490_linux_arm64.tar.gz"
      sha256 "a10ccbf2046f4fb82b31e9f33753b57b1adfee98ca70535c69ffdf8cfff9805f"
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
