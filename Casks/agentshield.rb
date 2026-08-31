cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2001"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2001/agentshield_0.2.2001_darwin_amd64.tar.gz"
      sha256 "b7fe3fc2dfc9bd0b6677dbeb8817e1bad6ce36bf2afe63ba532d382345f0727e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2001/agentshield_0.2.2001_darwin_arm64.tar.gz"
      sha256 "d5ed66bd6fba34e4905e4e81a76456436a2d8e7223f136edfc5c4dd040734387"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2001/agentshield_0.2.2001_linux_amd64.tar.gz"
      sha256 "7e6fda799dfe7b2770d384347c5b77bcbe369b3fe3fc6df2693571ac37cbf60d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2001/agentshield_0.2.2001_linux_arm64.tar.gz"
      sha256 "d1067f361ed1e610efb7d4c700b5137cee919480dd6a44d3707e5a448fa1e575"
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
