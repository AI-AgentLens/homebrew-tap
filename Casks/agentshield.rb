cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.662"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.662/agentshield_0.2.662_darwin_amd64.tar.gz"
      sha256 "42587fdca16d42fc030d3576263013bace2de5a069f68696d228c58ca1975212"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.662/agentshield_0.2.662_darwin_arm64.tar.gz"
      sha256 "e6f9d61c3d08f6df7beaa37d93619cd001ec4a352188a522d1c43fe44b691c5a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.662/agentshield_0.2.662_linux_amd64.tar.gz"
      sha256 "998a5f0477d5867875ace4782c787a21ffd9d121f98069bc5bc47d2e0b43b70e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.662/agentshield_0.2.662_linux_arm64.tar.gz"
      sha256 "354906fa45a8d3b65e1e09fb4aeb669616bcfa93db6fc949da2714f1e521677d"
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
