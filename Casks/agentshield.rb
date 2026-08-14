cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1849"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1849/agentshield_0.2.1849_darwin_amd64.tar.gz"
      sha256 "4b0ec308d0fa142ab8aa88f4073702bd21345a289313ca8fe4c2e63aacd14d0f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1849/agentshield_0.2.1849_darwin_arm64.tar.gz"
      sha256 "a35095c879ed46fb160e6cd4a28ef483d2b0a87881fcc261ea94e475a0af180e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1849/agentshield_0.2.1849_linux_amd64.tar.gz"
      sha256 "6a75185732537800871b57d95fcf5d6cc63727103f4931f83086cd4026351402"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1849/agentshield_0.2.1849_linux_arm64.tar.gz"
      sha256 "d0e06f8b662c35f297061eb20474b36dc34f8c386da3b1595866e5a757b232b5"
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
