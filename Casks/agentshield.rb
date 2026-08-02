cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1775"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1775/agentshield_0.2.1775_darwin_amd64.tar.gz"
      sha256 "fd81630eabc7618f92eb5743a34a199980d7d4ef073ae24e3b327f1244f32962"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1775/agentshield_0.2.1775_darwin_arm64.tar.gz"
      sha256 "0fc486e9e76578371dc49a0cd95945a4fafb493a355e46b84ba8982285510917"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1775/agentshield_0.2.1775_linux_amd64.tar.gz"
      sha256 "c2f3821f66c9008524901ee40a0633201bcf6f105c5baff8e2c8dcea66bc2c0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1775/agentshield_0.2.1775_linux_arm64.tar.gz"
      sha256 "ccc9dcc973915ea125f129761a0864131f3db9e1e8698f73c8eb907f6b8532b6"
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
