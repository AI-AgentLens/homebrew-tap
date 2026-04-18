cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.645"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.645/agentshield_0.2.645_darwin_amd64.tar.gz"
      sha256 "312be0dc7b23403d60a6c87a00660436618975606b90e88b10fea56291c2d660"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.645/agentshield_0.2.645_darwin_arm64.tar.gz"
      sha256 "9a8ed865b5619ea4b9a89186f43a3373131b89779a3ad03027393c5dbffd16d9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.645/agentshield_0.2.645_linux_amd64.tar.gz"
      sha256 "50aa4aa8003569500935b2334949d5f6c249ea0fc68e071743126adfc81547da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.645/agentshield_0.2.645_linux_arm64.tar.gz"
      sha256 "be63e3382423344fc6b5f2fa23c960240866c5b803552bba76078f646ecf1bf2"
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
