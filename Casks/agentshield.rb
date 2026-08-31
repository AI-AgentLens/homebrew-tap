cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2000"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2000/agentshield_0.2.2000_darwin_amd64.tar.gz"
      sha256 "866d15ae27b9bd793f1692ede29f9d8ee4f64767d4b9824d4813c519f4d84b4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2000/agentshield_0.2.2000_darwin_arm64.tar.gz"
      sha256 "1ba2386c5318ed9b7520fb85d8ce2fd8911599bc2429444b5897a97668e6f17f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2000/agentshield_0.2.2000_linux_amd64.tar.gz"
      sha256 "cf44191b88c94f53168c3703f1185c7d939411eff7f585269bf887410724128c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2000/agentshield_0.2.2000_linux_arm64.tar.gz"
      sha256 "14291c8502e134c299be03955801d32179c80cd815b054936b985f3a45aa343e"
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
