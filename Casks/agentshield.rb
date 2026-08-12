cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1832"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1832/agentshield_0.2.1832_darwin_amd64.tar.gz"
      sha256 "e62d68a5ddadca6b6667e261be42db3b24b8e1730d3531ca1d88a6519995fed4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1832/agentshield_0.2.1832_darwin_arm64.tar.gz"
      sha256 "3a95afbba380f7dce329abcfa727f62a948134e97b945b1e5b90e718db0ca3d2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1832/agentshield_0.2.1832_linux_amd64.tar.gz"
      sha256 "0c67d081772fb9633a859a3995e15d84f0e8a6f64abf63332f14c8e42ed2b2f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1832/agentshield_0.2.1832_linux_arm64.tar.gz"
      sha256 "061b67d33ec549fc6fb6164178c4452a6fcfd8a87ca60c5fadae1a0a3d76c7bc"
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
