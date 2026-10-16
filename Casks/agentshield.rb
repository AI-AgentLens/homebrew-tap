cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2445"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2445/agentshield_0.2.2445_darwin_amd64.tar.gz"
      sha256 "f78b71143633e4520923ed3534b40962760a296f06eff0b376d4481b28cff189"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2445/agentshield_0.2.2445_darwin_arm64.tar.gz"
      sha256 "f26d743a4c71b3e9b585c39feb33448f31f899a4dfb98e336f8dea08f787ab83"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2445/agentshield_0.2.2445_linux_amd64.tar.gz"
      sha256 "a226ad37831635a29c6643f898f1ca522c87fec8169dd79437fb6ce561d8aad9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2445/agentshield_0.2.2445_linux_arm64.tar.gz"
      sha256 "662f3484181ba213c655e292eee7fd2c837ed4f0fdac800fa1ad4518247ce8b2"
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
