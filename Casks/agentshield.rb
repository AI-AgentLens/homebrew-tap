cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.835"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.835/agentshield_0.2.835_darwin_amd64.tar.gz"
      sha256 "24e76af2cf4c8fc765c1b79d33f274fb98c3d04186065d54d038d54fa829c12a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.835/agentshield_0.2.835_darwin_arm64.tar.gz"
      sha256 "016c15789f473a4c24520b444ad81153c77c23ea3051c0482f6f1165ffd4521b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.835/agentshield_0.2.835_linux_amd64.tar.gz"
      sha256 "ada42a76e528b8cdeee3216e6b88e4680332103bfbe4b808d9772be7c3b1407b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.835/agentshield_0.2.835_linux_arm64.tar.gz"
      sha256 "a96904911a9bdffeccf776364af61373a47a56746bb90ddcf8ad33fb082f3b52"
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
