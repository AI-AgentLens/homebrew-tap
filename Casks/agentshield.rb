cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1929"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1929/agentshield_0.2.1929_darwin_amd64.tar.gz"
      sha256 "200bb366ea759bd3d1cb64543ae31327d2e687e2cc749a8fbf704db17002efb6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1929/agentshield_0.2.1929_darwin_arm64.tar.gz"
      sha256 "70eb36f22a7e6d30e271246958ac232e988c3ee067c6c3d24357a487809edd18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1929/agentshield_0.2.1929_linux_amd64.tar.gz"
      sha256 "1c7a47b84fc195839d0965430617ba213b192e09f2fe9deb6d4f006fb23beca3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1929/agentshield_0.2.1929_linux_arm64.tar.gz"
      sha256 "110dd6e8aaa8bc9fc6589f584caa4780dfc3cadc5b1e3a559773740e31505be8"
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
