cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.489"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.489/agentshield_0.2.489_darwin_amd64.tar.gz"
      sha256 "7bafdfeabb5188dd82c485a66210afcb41da5768adaf07d3e6f96298d4fdde42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.489/agentshield_0.2.489_darwin_arm64.tar.gz"
      sha256 "6bc0e9f28ba5552b3841c4a0c11d203603c71b838486ff08fb7970f6ecf713f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.489/agentshield_0.2.489_linux_amd64.tar.gz"
      sha256 "986e25c23c87b1ce66050a77c65720128dc5faa3299001d6bbd51e59d7ce1280"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.489/agentshield_0.2.489_linux_arm64.tar.gz"
      sha256 "a883dec0031ae3ca839ac8266a1a1668769ba5d3a30da472a44d43ccde37d53a"
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
