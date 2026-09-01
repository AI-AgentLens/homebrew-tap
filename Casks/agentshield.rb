cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2015"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2015/agentshield_0.2.2015_darwin_amd64.tar.gz"
      sha256 "dcd4ff37741b877f6941e7166e68476abf34443c64770bad9bc03226d0c12d65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2015/agentshield_0.2.2015_darwin_arm64.tar.gz"
      sha256 "5470ca9af374f43355aeb5651abf483be1a64d7632a7f8cf6eb361e2930d7bbb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2015/agentshield_0.2.2015_linux_amd64.tar.gz"
      sha256 "b500f35a5df3de26ef18065ff40811469d22250d9e33627d8e74d56fb5c203c1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2015/agentshield_0.2.2015_linux_arm64.tar.gz"
      sha256 "e7e45ebf94b38b0286f1e10cfe31963dcb9e99d0eb199a37513ea7184194c6fc"
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
