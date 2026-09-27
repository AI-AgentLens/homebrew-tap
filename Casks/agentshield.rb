cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2272"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2272/agentshield_0.2.2272_darwin_amd64.tar.gz"
      sha256 "9803cb4b74201e82b926f92e9a20647205c95dcaa676840ec918a6b973c17b81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2272/agentshield_0.2.2272_darwin_arm64.tar.gz"
      sha256 "9793d8a3c227be04e1edca838c1f6c15e2a730ddb8dff044593b4989ff7f8f7b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2272/agentshield_0.2.2272_linux_amd64.tar.gz"
      sha256 "d489eace09b6fbb9bcbd989d86fb51f4f1460c37605ff5a9eae970e5a8eea073"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2272/agentshield_0.2.2272_linux_arm64.tar.gz"
      sha256 "dd723d5e3124075bdaf961a06550d929ecd676e8f13256b8f0500cfb31840b58"
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
