cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1455"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1455/agentshield_0.2.1455_darwin_amd64.tar.gz"
      sha256 "c0e1f30cc4cd4a30018a5a97c9c3f4dcb2ea1f61368a5c013113b4f85241cb69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1455/agentshield_0.2.1455_darwin_arm64.tar.gz"
      sha256 "3ba8269573b29496b467955dae8e36560512bd88b1e2c94880fd11671715bd07"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1455/agentshield_0.2.1455_linux_amd64.tar.gz"
      sha256 "c5a12942b74439425e37e035d723ce5435f46ca3d089958a15c294b660421fa9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1455/agentshield_0.2.1455_linux_arm64.tar.gz"
      sha256 "bd4aeed8b1d767814b91da98e8c541d34e99243f6e36490487cc2d5f3f0a14f8"
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
