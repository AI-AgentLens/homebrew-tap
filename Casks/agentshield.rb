cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1324"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1324/agentshield_0.2.1324_darwin_amd64.tar.gz"
      sha256 "bc5d1d3bed4ded9c93332b40ce6b168550f300bd4dc6cd90ee6691f8f367caf0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1324/agentshield_0.2.1324_darwin_arm64.tar.gz"
      sha256 "b287b6be9ab5d08476a9e8362ca6493945dceac1bca2b4e510fda154ec8b658c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1324/agentshield_0.2.1324_linux_amd64.tar.gz"
      sha256 "1b588288c33173200e5250559137037ed47c3bebbcf4a55d139f059347d63517"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1324/agentshield_0.2.1324_linux_arm64.tar.gz"
      sha256 "53f1bd432a022c008af8cd229a9d793791b0bf1febbbf19e880e4615c98ea5c0"
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
