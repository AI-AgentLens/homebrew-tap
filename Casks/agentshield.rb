cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2475"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2475/agentshield_0.2.2475_darwin_amd64.tar.gz"
      sha256 "8dec5eb68dbbba9de5787c08c64884b296dc4a83f24f9db205dd66b6b18f6fb3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2475/agentshield_0.2.2475_darwin_arm64.tar.gz"
      sha256 "8b4e0ecbf6a331171fe1a5bd5bce8c18aa62e1238b2ea57f2593a08d896e6646"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2475/agentshield_0.2.2475_linux_amd64.tar.gz"
      sha256 "1fc85cd2abe177a3468c7be89e3cc054cf56b4d9da85bf9f59dbc23f3b4773ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2475/agentshield_0.2.2475_linux_arm64.tar.gz"
      sha256 "8f9d8d3a486a6090b69e274b30f19f2355911e74e8e5cfb53efdb327b8eaa8b6"
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
