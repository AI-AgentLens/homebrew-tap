cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2236"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2236/agentshield_0.2.2236_darwin_amd64.tar.gz"
      sha256 "9ae9f7ad9b015e835c44ac77a3fe4e5f63241dfb12e2f825c5cc08e5c9072b67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2236/agentshield_0.2.2236_darwin_arm64.tar.gz"
      sha256 "32079e2c4923302c1ec4b53d50fc154642f1757aab371660cb1040e2ca497c14"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2236/agentshield_0.2.2236_linux_amd64.tar.gz"
      sha256 "5c496cc7874659c2ac2df8a6792ee7913844c30459ea0e08f3b8d74f02a4612b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2236/agentshield_0.2.2236_linux_arm64.tar.gz"
      sha256 "a94af6d3299a4776696a7da81d0ffe708d511e3a59b3e115d3255ba0f523949e"
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
