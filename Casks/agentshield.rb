cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2128"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2128/agentshield_0.2.2128_darwin_amd64.tar.gz"
      sha256 "1bcb1f8146f72adb141185f4e8866bb5be9196eb939cfd01a19bcbb2c338581e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2128/agentshield_0.2.2128_darwin_arm64.tar.gz"
      sha256 "4068bda08c4810d9516c3a5b63fed2e6df5e09affe434c89cc5ad7a5c4cb9ecb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2128/agentshield_0.2.2128_linux_amd64.tar.gz"
      sha256 "4e59429afadd9629241815ee1094cfdee4f13dab8d9739bdef8d3e4d732bba17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2128/agentshield_0.2.2128_linux_arm64.tar.gz"
      sha256 "af6573e84b914b2da098ffb25d988aa7e61dbc1fe27fa4aa671236167c4d1e61"
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
