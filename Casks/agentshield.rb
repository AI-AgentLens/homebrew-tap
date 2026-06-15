cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1322"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1322/agentshield_0.2.1322_darwin_amd64.tar.gz"
      sha256 "5767d833c9812b6cbce1eac746db40e58d6506ac6a55e79b646a01986da626dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1322/agentshield_0.2.1322_darwin_arm64.tar.gz"
      sha256 "f0a4172c8d93a274af03d40bbeb3f77ca70b113a9b810d2287d065892bcee3ab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1322/agentshield_0.2.1322_linux_amd64.tar.gz"
      sha256 "1c558aac2d35adee4c490ee09470375c28e60b9481217ee88b17e585c02c6c17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1322/agentshield_0.2.1322_linux_arm64.tar.gz"
      sha256 "d2e7317cf3aab39a7e3228d6180c2f2104535d78374f361b6f71ed485dea2bea"
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
