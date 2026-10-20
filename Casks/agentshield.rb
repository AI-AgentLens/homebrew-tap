cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2484"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2484/agentshield_0.2.2484_darwin_amd64.tar.gz"
      sha256 "1908276198f8d858d0545d12bbb80eeb8a3e68def002006f44d93fcd1f8b8cdb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2484/agentshield_0.2.2484_darwin_arm64.tar.gz"
      sha256 "ea63f66c92aff8a40fc855acb02db8b1e823d6d7fc12987fdc6d209997578699"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2484/agentshield_0.2.2484_linux_amd64.tar.gz"
      sha256 "5755677d267de4b663517a1c85f7d9071b9986ded65a24bb84bcbac072c7a3f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2484/agentshield_0.2.2484_linux_arm64.tar.gz"
      sha256 "a20431333196d46aee269e8600cb61d3dc22071d339062a71bb0a37bb4a88e10"
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
