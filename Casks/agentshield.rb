cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.737"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.737/agentshield_0.2.737_darwin_amd64.tar.gz"
      sha256 "dcf243cc27e5ac7716eff7f01b45a4ca3f6633526e6ee3bcc5e5295d820d309c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.737/agentshield_0.2.737_darwin_arm64.tar.gz"
      sha256 "6152c9a52c4831dcf648c3dfb20bddd4e9bf1abddf590039dcf054ca04e1fa7d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.737/agentshield_0.2.737_linux_amd64.tar.gz"
      sha256 "c6cfe44927d3472a769775b6b165c92d1892b2f04fe27fc7dc3eedac460d8e35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.737/agentshield_0.2.737_linux_arm64.tar.gz"
      sha256 "5593ab9dbcb19c4c061ab613ccd0dfc308b8055812c8f22bf797a6466f42dac8"
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
