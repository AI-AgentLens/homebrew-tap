cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1594"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1594/agentshield_0.2.1594_darwin_amd64.tar.gz"
      sha256 "7d85c54e6024f839535a0925c09a3358c090b64d7f3eb650fe9ebd94c044de37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1594/agentshield_0.2.1594_darwin_arm64.tar.gz"
      sha256 "a1b3d29163ad0d4ea2d8e1c0a68dd0529cf53a08c4fb1b0e2328d09c082c125f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1594/agentshield_0.2.1594_linux_amd64.tar.gz"
      sha256 "7b7f586268d44a2da6164439d0a1f3b8d981802c7f80dc4dae2f0d7233d7b386"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1594/agentshield_0.2.1594_linux_arm64.tar.gz"
      sha256 "cb262c164f4da2d9d5db641aeb1270da5f3781aa0aea5bd11acd2fc77d40939a"
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
