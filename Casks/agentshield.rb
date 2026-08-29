cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1986"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1986/agentshield_0.2.1986_darwin_amd64.tar.gz"
      sha256 "f1b741362b6126893e94bfb00e48ebedde6ee86b77e080b1b41bd07e18856993"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1986/agentshield_0.2.1986_darwin_arm64.tar.gz"
      sha256 "2136e847caf020d91fdb4ca3febc717c067d45310e3f5872e8c9ccc037b8f497"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1986/agentshield_0.2.1986_linux_amd64.tar.gz"
      sha256 "a390fe654854598cc87934444dcecb1c1657f835fbfd063fb7f9bad76f34d78c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1986/agentshield_0.2.1986_linux_arm64.tar.gz"
      sha256 "d3f0b7a0a4605ef518c0dd7d41861882314df38e407edfe2ea55276c2b727aa7"
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
