cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2327"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2327/agentshield_0.2.2327_darwin_amd64.tar.gz"
      sha256 "9d8c0b955dfdce9379e4cc703231b35ec9a2155b3c3b84d80480a146fb0fb12b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2327/agentshield_0.2.2327_darwin_arm64.tar.gz"
      sha256 "e20a7924cac7960bd91d54c61a18e1cba76bc857767ff5c04da2496d24a7d75c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2327/agentshield_0.2.2327_linux_amd64.tar.gz"
      sha256 "e07701a0a3df8b235269baa3b59d915dd6aadc6b537391205f7f0112a908d88a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2327/agentshield_0.2.2327_linux_arm64.tar.gz"
      sha256 "02ac22ce8ecfc164225d2b44bd66846c43270c4ee1b6f307469a8adc8654cb79"
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
