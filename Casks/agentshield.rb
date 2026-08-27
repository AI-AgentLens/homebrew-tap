cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1965"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1965/agentshield_0.2.1965_darwin_amd64.tar.gz"
      sha256 "d596ff628f7368ce02c9b59f5d0db766c530c443fa765aa6525f19be4dd5126a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1965/agentshield_0.2.1965_darwin_arm64.tar.gz"
      sha256 "e5c56e78f94bf6e63c04d2508dbee9cfd42bd2f055a3fe3a9fa1713c759d7cc7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1965/agentshield_0.2.1965_linux_amd64.tar.gz"
      sha256 "8dfbfab3858761a6099ad45d69456212f776802e5fb7059bae1965bb00871709"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1965/agentshield_0.2.1965_linux_arm64.tar.gz"
      sha256 "e0f997eca142daef3ed20bf96fe7002e6154d01c5ae48390f85ab6e2ffde27a8"
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
