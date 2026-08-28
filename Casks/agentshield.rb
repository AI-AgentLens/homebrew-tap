cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1972"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1972/agentshield_0.2.1972_darwin_amd64.tar.gz"
      sha256 "eb309482e8dc30dbff9f90226b431dd708e5dc1d11ac0df293d46478817f620b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1972/agentshield_0.2.1972_darwin_arm64.tar.gz"
      sha256 "5a7606dd6cbe9a493c0f68cc2b0aa711c192ee2e7e02d3eb1c1be67a826a6249"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1972/agentshield_0.2.1972_linux_amd64.tar.gz"
      sha256 "2b831dc49ad8c37d3a6e9612d09f15425f283a58934b343a83395ed2301a3550"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1972/agentshield_0.2.1972_linux_arm64.tar.gz"
      sha256 "1f30295891d614161c9070ceb8017848c3d8f97143d3810f1747e4514cc065ef"
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
