cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.644"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.644/agentshield_0.2.644_darwin_amd64.tar.gz"
      sha256 "74122e301eb0359637ea1fdd69475f341f406e2e18d586ccc0e026f02c569d6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.644/agentshield_0.2.644_darwin_arm64.tar.gz"
      sha256 "de979157c89926413dcc1f138758224afa4ff04b57185e7bb1a2e0eb579faa64"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.644/agentshield_0.2.644_linux_amd64.tar.gz"
      sha256 "8f11ffba11898b217ea89f2002125f5fa6be10cc5c02210b24b9af81cb056e96"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.644/agentshield_0.2.644_linux_arm64.tar.gz"
      sha256 "e2ede0e9739c4d7ac701edb966ffaa3c9aa3648a6eaa791072cc2e5352286080"
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
