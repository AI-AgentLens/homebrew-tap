cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2481"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2481/agentshield_0.2.2481_darwin_amd64.tar.gz"
      sha256 "cd99f8598dc08098dfd8fc7b3fbf39fe023a3e43fcb702f3570fa8981b8b3663"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2481/agentshield_0.2.2481_darwin_arm64.tar.gz"
      sha256 "d139632c492088a27fde826598332b2300262d995d7639d12d8c052c68dd86ed"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2481/agentshield_0.2.2481_linux_amd64.tar.gz"
      sha256 "67bf50502a411e8aa19132da2224b1bba59a0e902d2fb9b1fe2b69d1720aced2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2481/agentshield_0.2.2481_linux_arm64.tar.gz"
      sha256 "aa855a118da7ffce76790621ddc3d88da6b2cc4083c5b8179a3246c6ba9d885e"
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
