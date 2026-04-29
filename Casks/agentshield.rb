cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.815"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.815/agentshield_0.2.815_darwin_amd64.tar.gz"
      sha256 "364d2b3d14128b6a31b9f34ff655a95d1ab141120a9264d4916864e2038a1690"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.815/agentshield_0.2.815_darwin_arm64.tar.gz"
      sha256 "deaa1e24d823d1ad77fe0d1658c110802e7848e2062c414d4f6860f3d7c30ff9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.815/agentshield_0.2.815_linux_amd64.tar.gz"
      sha256 "2a428b6d95a9ad081494884858869c8f9522f66b3376b8fb7505598bf5f64026"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.815/agentshield_0.2.815_linux_arm64.tar.gz"
      sha256 "4a65ac03dd622d56b4d5c112884ea7bb4ae0191e1716aa7852d8e43acdfcbaa7"
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
