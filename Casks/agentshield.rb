cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.298"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.298/agentshield_0.2.298_darwin_amd64.tar.gz"
      sha256 "9a562dd950fa6e0a977f78614671c29fe78d148ffceb30d33363df02929a7204"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.298/agentshield_0.2.298_darwin_arm64.tar.gz"
      sha256 "56d9f83d805528f695ba7566bb13cf72f5c66898fcc8c831156e98c2b492d446"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.298/agentshield_0.2.298_linux_amd64.tar.gz"
      sha256 "d9ce9892c76de569a24c295d843204df24a53a52771e70f0b0477767f950773c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.298/agentshield_0.2.298_linux_arm64.tar.gz"
      sha256 "b3f09826908a5dd2b435dbfc3e5c976e1115e0e076e505cf6f7e9887b7d658b4"
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
