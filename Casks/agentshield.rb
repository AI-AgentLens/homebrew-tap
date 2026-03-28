cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.174"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.174/agentshield_0.2.174_darwin_amd64.tar.gz"
      sha256 "40de23351e4f60ec83db1f8fca21b260fab79118751d39ac62db5de8c6fc4aee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.174/agentshield_0.2.174_darwin_arm64.tar.gz"
      sha256 "cee95458d7998974a89004ecaf03ec1ccb703b8a43f0fe4f24f8fa432f5e84ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.174/agentshield_0.2.174_linux_amd64.tar.gz"
      sha256 "fca4870917d3ab0447925a18115c66f21e9f02a6346fdb0b5958089d5c37279d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.174/agentshield_0.2.174_linux_arm64.tar.gz"
      sha256 "068f05192cfbec0077bad897731f7fa6d338147520d62f80baf74896e3d04486"
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
