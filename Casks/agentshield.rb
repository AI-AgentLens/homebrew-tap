cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.711"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.711/agentshield_0.2.711_darwin_amd64.tar.gz"
      sha256 "0b64850709d2d90f9f9831d3bdd88f5cac3ea32ebc834749e73a231640379d58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.711/agentshield_0.2.711_darwin_arm64.tar.gz"
      sha256 "44c2347ed8742aad7404dcdac949319af58ea53dd0fe829b4669af603c786c75"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.711/agentshield_0.2.711_linux_amd64.tar.gz"
      sha256 "0b930a5ebaa575b88e448e196cea46ab8c071366462f9fb77ebafb61f3a60c21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.711/agentshield_0.2.711_linux_arm64.tar.gz"
      sha256 "07342aa7fa9c3910644ee4589817bb341cc6788b2e23f7538444f2780c13df7e"
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
