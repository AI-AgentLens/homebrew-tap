cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.138"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.138/agentshield_0.2.138_darwin_amd64.tar.gz"
      sha256 "38e092742a4d76d9dd3c61a4180c395d78b19470219844348050b4e2f6e6e694"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.138/agentshield_0.2.138_darwin_arm64.tar.gz"
      sha256 "39f5ef393e93b87a5e11dd9bfe37a9bce8b874c32581898546ec5e8dcf80081d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.138/agentshield_0.2.138_linux_amd64.tar.gz"
      sha256 "1d1f109fe3e709d75f031c3a75041cb480525fd1dc5273b0115736bb584bd0bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.138/agentshield_0.2.138_linux_arm64.tar.gz"
      sha256 "913f023419f4ca43fc6f764381e2bf9237718339c794a81c93ced927c16581bc"
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
