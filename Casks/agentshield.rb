cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1835"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1835/agentshield_0.2.1835_darwin_amd64.tar.gz"
      sha256 "071cb1b6fad06119844715f3731ec59c5b55e0fdc0ad169b936b23284a768341"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1835/agentshield_0.2.1835_darwin_arm64.tar.gz"
      sha256 "5205bc4a10ad2a46a46d1acad97a09c8293ec28c1fc16db0dc75942ff399c2c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1835/agentshield_0.2.1835_linux_amd64.tar.gz"
      sha256 "4935b347318cbc6ab9271c520990efc8b74edd1c22e3ebcdf221add5e02c9eb5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1835/agentshield_0.2.1835_linux_arm64.tar.gz"
      sha256 "af719b7531387d85bf122a4098665e068730e0b3c0cdfcb3b71b046b7e92d116"
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
