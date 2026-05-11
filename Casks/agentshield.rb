cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.945"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.945/agentshield_0.2.945_darwin_amd64.tar.gz"
      sha256 "9285356b87f2e507403e68eb3c94923f85c55a27df7852f1aca686df8383a5ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.945/agentshield_0.2.945_darwin_arm64.tar.gz"
      sha256 "f03bf572c1df0aef48eb95fc49a01e041a895fb67d66b237c7e962b47de13cb0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.945/agentshield_0.2.945_linux_amd64.tar.gz"
      sha256 "5be6c2e2d037edd847151e284748363e398581af245900e382764ad7478a2d66"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.945/agentshield_0.2.945_linux_arm64.tar.gz"
      sha256 "12714d07883752a149fb811159fc290b154f621e63a7de383410c53a6763b620"
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
