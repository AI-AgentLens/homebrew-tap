cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2512"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2512/agentshield_0.2.2512_darwin_amd64.tar.gz"
      sha256 "e054679b8a2f54dbc03ece917af2628210e9671cda974df6540d36609457e754"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2512/agentshield_0.2.2512_darwin_arm64.tar.gz"
      sha256 "f704cea1f053127eb2b65568c6353265017c6f809479a704bd2d5ca8785d722b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2512/agentshield_0.2.2512_linux_amd64.tar.gz"
      sha256 "221ccba4c94bbfb5c636cbd23c21ccc316347801acc8f91a274c55be09ec3048"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2512/agentshield_0.2.2512_linux_arm64.tar.gz"
      sha256 "dc47cb0518d112c937c8027c24cfa6fd56c0cce8d291354662408fc345f1e513"
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
