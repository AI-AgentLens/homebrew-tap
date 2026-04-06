cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.427"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.427/agentshield_0.2.427_darwin_amd64.tar.gz"
      sha256 "874a37e921f3b3c6a052fe3170e4dd2ef927597be1af95fb8c346e43213d0014"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.427/agentshield_0.2.427_darwin_arm64.tar.gz"
      sha256 "3a6de49eec5eb1f9d2bc5394066dc5457e0c535baf5b6a507f55d3d31b6e9a46"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.427/agentshield_0.2.427_linux_amd64.tar.gz"
      sha256 "d6c3ebdc851023afce184d3be0a2529150889fbefe3160a0fce6e1df759c8d5a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.427/agentshield_0.2.427_linux_arm64.tar.gz"
      sha256 "21b10bbf46354103879a5ba2a47c9075e08ebdacf59186ba2648b753d740ad3f"
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
