cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.493"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.493/agentshield_0.2.493_darwin_amd64.tar.gz"
      sha256 "7d2c5f3c8e264e15e9e3a1abedae27f2a9de08fbb9b1480f00cf282bef40b48a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.493/agentshield_0.2.493_darwin_arm64.tar.gz"
      sha256 "45934a9e790af298686e6677aab8eea409413f75a8b288c7b153b778416331cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.493/agentshield_0.2.493_linux_amd64.tar.gz"
      sha256 "d8ff8b0903964ab3ca032be5806775ddd01f84fea9880e4653b5d355926b64c1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.493/agentshield_0.2.493_linux_arm64.tar.gz"
      sha256 "a1c105f12e64cd823562eb242c2b9bb67eb96b9d156e8838160297e9cb01f040"
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
