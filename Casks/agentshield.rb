cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1821"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1821/agentshield_0.2.1821_darwin_amd64.tar.gz"
      sha256 "c7a2aad369dab189d2b481b2f5870cb11cd905f292ad6e56b7d9605f6061dca0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1821/agentshield_0.2.1821_darwin_arm64.tar.gz"
      sha256 "5d7df322084d0d1523a37b2630a265c29d6766436c46cfc97ae45c658a26db89"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1821/agentshield_0.2.1821_linux_amd64.tar.gz"
      sha256 "ddc5b7601a58543c7c53c620a3caa1949fc6d35e262edf2d0876b56da57739f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1821/agentshield_0.2.1821_linux_arm64.tar.gz"
      sha256 "99fd2f81c55770f6ef9df31f6323540414983535fd64463441106cc32706883b"
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
