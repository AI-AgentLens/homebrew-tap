cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.254"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.254/agentshield_0.2.254_darwin_amd64.tar.gz"
      sha256 "9cdb52df747ca58d4815dbc2a579268b8f3754ef3de7c4c7f3d02c0ce2447079"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.254/agentshield_0.2.254_darwin_arm64.tar.gz"
      sha256 "f1c9e517d80afc4ad28187177d1f336b622c4b3fec83067ef1cea57c75920aee"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.254/agentshield_0.2.254_linux_amd64.tar.gz"
      sha256 "0aeac38abe0b2fb60fb1a28ba1d4ac25d81b4408fd03daeb1e6a54b7c760b731"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.254/agentshield_0.2.254_linux_arm64.tar.gz"
      sha256 "a7c721bd6d7d6e75daa0005b92cbf518305dc7467091cd89b822c4c58bb3b700"
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
