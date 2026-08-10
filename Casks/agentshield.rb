cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1813"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1813/agentshield_0.2.1813_darwin_amd64.tar.gz"
      sha256 "b456a79fdc6c2c743f0a09f94fe61794c09288710f71f39fee7d3789a251fee4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1813/agentshield_0.2.1813_darwin_arm64.tar.gz"
      sha256 "7a61ff1898c01d1fd092c240a4f37d4cee1e3b6ec5cadde7fe9b842d07c12aa9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1813/agentshield_0.2.1813_linux_amd64.tar.gz"
      sha256 "dba13a674c6828bdf7419a5c3c0d8bc21717f5e0766192f24f832e02aa46ceca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1813/agentshield_0.2.1813_linux_arm64.tar.gz"
      sha256 "f52a67113503e4b73771cf5ef0d9fdf16ea13161838d1c55614057651e0aef63"
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
