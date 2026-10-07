cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2378"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2378/agentshield_0.2.2378_darwin_amd64.tar.gz"
      sha256 "efb953844621716ee0c627526843ab562cb1764fddc20386bd7edf07401158c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2378/agentshield_0.2.2378_darwin_arm64.tar.gz"
      sha256 "dac99df9c4279281991b2109506ffb0ee68a9965bed47e3cec514d51caf333b1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2378/agentshield_0.2.2378_linux_amd64.tar.gz"
      sha256 "633cf73063a33a4b0a3978724076bde92df77f8c9e70e429620783187a1a21ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2378/agentshield_0.2.2378_linux_arm64.tar.gz"
      sha256 "185e4860466ee3a8275c0a3c83b32e37d590e298bb9546eecb5370ae27c2444c"
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
