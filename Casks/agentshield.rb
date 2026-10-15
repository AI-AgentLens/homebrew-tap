cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2437"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2437/agentshield_0.2.2437_darwin_amd64.tar.gz"
      sha256 "d868a20e69bf59c4e00c70f2b7417e9720d3037ddff9bb7d6f3d7df2d8529889"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2437/agentshield_0.2.2437_darwin_arm64.tar.gz"
      sha256 "af6bb8184dfafe9965ac369fc612612c2ceec068949806acfad8d4e1dc86c495"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2437/agentshield_0.2.2437_linux_amd64.tar.gz"
      sha256 "95a1bb520a8c4b9eeb244fdab5c1ad612904806e0a13b70ba6d66299942a677c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2437/agentshield_0.2.2437_linux_arm64.tar.gz"
      sha256 "c7f7a6c2dbd24ee105d9d56c6d39618c0c48e64f01911c69d29df48c90ce633c"
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
