cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1952"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1952/agentshield_0.2.1952_darwin_amd64.tar.gz"
      sha256 "620018f60ae92e985ba401c975042f1df592ebc62fad4965b7800db9133d3d81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1952/agentshield_0.2.1952_darwin_arm64.tar.gz"
      sha256 "0982ebe2299e0503858e6bcc1b48104e2f5df0fd4f30306ab56c17fcedfb233b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1952/agentshield_0.2.1952_linux_amd64.tar.gz"
      sha256 "022da366bc9384915d09ddf85b960fd92e3a59408b809cb79d5cf816f87eb4d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1952/agentshield_0.2.1952_linux_arm64.tar.gz"
      sha256 "28cb23394e7d38651b2dec4e4563bf2fdee37bf5a491a7c7693714eee0a53a99"
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
