cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1796"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1796/agentshield_0.2.1796_darwin_amd64.tar.gz"
      sha256 "ec4e9fbd0a2c32d9aefb577809772f551bfb9387fb0be4fb801be22c5bf9415d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1796/agentshield_0.2.1796_darwin_arm64.tar.gz"
      sha256 "f4fac291c3d1aa500369d156c2059c371f218dcc354a8a5a0fbe7822ea627487"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1796/agentshield_0.2.1796_linux_amd64.tar.gz"
      sha256 "9c4bb75a9490bf554b9db5d1d94be119dc08018e3404998a1423fea7fe3e15a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1796/agentshield_0.2.1796_linux_arm64.tar.gz"
      sha256 "b6d3b8516ae4b6465a79a45b111e8f98171e7a37193cc4f3f0f8aa268eb73662"
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
