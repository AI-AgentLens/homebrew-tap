cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1345"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1345/agentshield_0.2.1345_darwin_amd64.tar.gz"
      sha256 "abe276ebce68e98c8ffb9f4a180927576cb5619c791f27bb246469459f172a00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1345/agentshield_0.2.1345_darwin_arm64.tar.gz"
      sha256 "ced25cbdd56783765d0d557717397ddece0548f71f05ec689b6618ff95d4bbfe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1345/agentshield_0.2.1345_linux_amd64.tar.gz"
      sha256 "153f7772a3d9efef500969c027cd1d5009b6b62c89d88dc9ebd4281627bff9da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1345/agentshield_0.2.1345_linux_arm64.tar.gz"
      sha256 "b5fbacb511d53177f5e36ed7b4bd0b0ba42b08422e0df0169a21209184bad4de"
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
