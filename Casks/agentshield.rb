cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1065"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1065/agentshield_0.2.1065_darwin_amd64.tar.gz"
      sha256 "6710be8b459d665ecb4fb70397bb752c311a0a92ca4b7c3f142c6f14c09c82b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1065/agentshield_0.2.1065_darwin_arm64.tar.gz"
      sha256 "a551c5008afac6b4c2bc2750e930e758f1f1ffcf5b68b155c69ac3b56404e762"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1065/agentshield_0.2.1065_linux_amd64.tar.gz"
      sha256 "0e2166ce3b07f2d73f823f872009e2026cc79deb62256c270fbb8c5a250a8c6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1065/agentshield_0.2.1065_linux_arm64.tar.gz"
      sha256 "2fc8ab9b4456212c592743f12984923e87e8e958e9f51d63b6a1f29d8020314b"
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
