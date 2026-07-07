cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1577"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1577/agentshield_0.2.1577_darwin_amd64.tar.gz"
      sha256 "95de91b54ca21fd96245c1253d464a79147c45522af45708907cf7d01c296b01"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1577/agentshield_0.2.1577_darwin_arm64.tar.gz"
      sha256 "69f745233885a3060cb5d90b139f6c2e32a65d6c6bca633e29b400f4cef408f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1577/agentshield_0.2.1577_linux_amd64.tar.gz"
      sha256 "cbfaa638ea7a816534a14f532cfc64f80d9286a99b53f473ce31527a8da79f12"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1577/agentshield_0.2.1577_linux_arm64.tar.gz"
      sha256 "70c8b997fae2139285f331f9012424dbb490c500020c8ae8ed8e3b3d62a90952"
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
