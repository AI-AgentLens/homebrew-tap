cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2424"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2424/agentshield_0.2.2424_darwin_amd64.tar.gz"
      sha256 "991d14f0a6991db81a5d86e58bd04f37c0d751fd02067b5cec4b9ef56bf5c0f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2424/agentshield_0.2.2424_darwin_arm64.tar.gz"
      sha256 "1f79182f3eb59c3fe5fe8ca25a05be58378ffcc2bf1e72fad2c886690239d80c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2424/agentshield_0.2.2424_linux_amd64.tar.gz"
      sha256 "28c0569b622d95e01f3ac8c55db89fa81c6c2a6e16a9ef7e02f6b7452d3a954e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2424/agentshield_0.2.2424_linux_arm64.tar.gz"
      sha256 "f2d4ce4e50c1c34970a97a9184221e0a5aeb2418099eb66add49ce0b552fe127"
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
