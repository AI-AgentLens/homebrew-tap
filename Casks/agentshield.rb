cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.973"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.973/agentshield_0.2.973_darwin_amd64.tar.gz"
      sha256 "98e9aa1ddae2880a06d88f7c977308eff9023079448de52210dec3119449874a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.973/agentshield_0.2.973_darwin_arm64.tar.gz"
      sha256 "33b88fb986a2f42b87ac941527e7bbf2790b9ef7e4a4151223f98723fbc40590"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.973/agentshield_0.2.973_linux_amd64.tar.gz"
      sha256 "b13aabebbd53b139ff65a37851da4ceaeb1ad8f5808781cd37b049b0dfd7f0e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.973/agentshield_0.2.973_linux_arm64.tar.gz"
      sha256 "a4fd63a86171d5ca12d2779ee285b387fe2b16bdffe1f1bc599f502d799c0b8b"
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
