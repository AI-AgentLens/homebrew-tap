cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2391"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2391/agentshield_0.2.2391_darwin_amd64.tar.gz"
      sha256 "e28a295853e646b6cc6fafdab7263846c34fba02031d667574bbe96be4ece87e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2391/agentshield_0.2.2391_darwin_arm64.tar.gz"
      sha256 "a590cdd549a358ef3c90e48fae2a0769239f7aa15d827997fe939e2ab0f9d90d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2391/agentshield_0.2.2391_linux_amd64.tar.gz"
      sha256 "5762ef187dd5b6cd9ef713c1033f482e28f709297ca8a0aeb14de627619dbade"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2391/agentshield_0.2.2391_linux_arm64.tar.gz"
      sha256 "4b167c2f0d5c1bde7502d15f55804ecb0b5a27651a871dff3879a34b73dcc9bd"
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
