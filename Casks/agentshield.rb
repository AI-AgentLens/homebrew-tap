cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.881"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.881/agentshield_0.2.881_darwin_amd64.tar.gz"
      sha256 "0e4e60361263b74e3b041d1f9494693c14005f57b27e8717b2897acfa7a4024d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.881/agentshield_0.2.881_darwin_arm64.tar.gz"
      sha256 "0dfb19ba1141b0d08872743dbfd13920bcc4eb093b38132f53afec0ff20ee56e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.881/agentshield_0.2.881_linux_amd64.tar.gz"
      sha256 "c4bf7c0d98829c71e1bf542c2259a33e38da8aaaae7c6be1e97148148a4805ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.881/agentshield_0.2.881_linux_arm64.tar.gz"
      sha256 "cf0a59bb8ce34a5650a233973201ad7fefbf3bf1b79f1eba7e8b39bad391d4bc"
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
