cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2047"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2047/agentshield_0.2.2047_darwin_amd64.tar.gz"
      sha256 "c2b5557a3c71cb14c0a2dc5e20589d65143f06c3977a28d386669d5b9d43e120"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2047/agentshield_0.2.2047_darwin_arm64.tar.gz"
      sha256 "f236fba081b548f80f414848e44ecc414d8ad07c888fd22f1f6caf79edf086ac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2047/agentshield_0.2.2047_linux_amd64.tar.gz"
      sha256 "77cf698427c1f51a920c8ba8c794286812dce3fd6b82a9cd9dd7c4ff366e506e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2047/agentshield_0.2.2047_linux_arm64.tar.gz"
      sha256 "d0b461fd58aa2b4eadd7d8c20a8cb9bbeae43ae5cc32b01ec7b132533c14be84"
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
