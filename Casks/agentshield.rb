cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2123"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2123/agentshield_0.2.2123_darwin_amd64.tar.gz"
      sha256 "0c305102bb4eefde248b70bceaad6a09900e827dd97e7325676b80664183857b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2123/agentshield_0.2.2123_darwin_arm64.tar.gz"
      sha256 "db651c7cdb604766b1e4e90d8c93b6fae3ad239bad9e5dae6042c4cc4376cd45"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2123/agentshield_0.2.2123_linux_amd64.tar.gz"
      sha256 "989074588b231944453dad8a28596f346a9cad879eae03d88193228957b61485"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2123/agentshield_0.2.2123_linux_arm64.tar.gz"
      sha256 "5f53682c59dea875c6a679f32420a81d6b6473327f3cddc5ac1e55619df49351"
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
