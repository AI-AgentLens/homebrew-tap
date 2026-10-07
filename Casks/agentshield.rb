cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2368"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2368/agentshield_0.2.2368_darwin_amd64.tar.gz"
      sha256 "ffc8c10ef0a23b41142d06fffb6888a19b189ee0588fc01c635bf427acbe0ab3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2368/agentshield_0.2.2368_darwin_arm64.tar.gz"
      sha256 "3f9482bf463b8106c03ba65cd1893bc0d22719dac60648a5c10230eec4ccd68c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2368/agentshield_0.2.2368_linux_amd64.tar.gz"
      sha256 "d1ca151250cf2e1e74aad3f0cb319f4dcb418e590d6257fb6caac0cbf49ec8da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2368/agentshield_0.2.2368_linux_arm64.tar.gz"
      sha256 "3c24308f02ebaafcd404fbd54905cc8ba1137c6475d7ab26dd60b4d57f71847b"
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
