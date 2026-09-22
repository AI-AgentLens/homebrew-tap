cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2220"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2220/agentshield_0.2.2220_darwin_amd64.tar.gz"
      sha256 "85fb0b15f973ca3cda393d545c94ddddd27ebc84aff7f309eef05d0cdb9e30aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2220/agentshield_0.2.2220_darwin_arm64.tar.gz"
      sha256 "85117dc906074bf1e49c1723b3e5d0235f9e578e769c2ee500343520a0b7bf41"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2220/agentshield_0.2.2220_linux_amd64.tar.gz"
      sha256 "91f1750ff3dbeb71ee27d2905a03dd4b228bb2abaecca7e6e094198d4648c6fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2220/agentshield_0.2.2220_linux_arm64.tar.gz"
      sha256 "5bfa33482a16b3dab3b05bd50c98625b7d222d1b74237d3729b15e5438e37464"
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
