cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.904"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.904/agentshield_0.2.904_darwin_amd64.tar.gz"
      sha256 "5930e6835474ca544892e8da227c99dee0796ae5462f113dfc93e60f4735cd6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.904/agentshield_0.2.904_darwin_arm64.tar.gz"
      sha256 "6c7d4cf7537c01a9b10a7369bbbb27c0655dff7ddfd2681ec8655b072c2d0c81"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.904/agentshield_0.2.904_linux_amd64.tar.gz"
      sha256 "3008df0d9ef4224e97f345e455e8a83717227a59acd4785ba9a6d85753314cdb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.904/agentshield_0.2.904_linux_arm64.tar.gz"
      sha256 "880c3fb5a99d8d1553b8fcbe9b3f519bd072438207a7435b212d2d5ee72f3140"
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
