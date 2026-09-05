cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2044"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2044/agentshield_0.2.2044_darwin_amd64.tar.gz"
      sha256 "855cb849eec90bc9819ae591e11116c48c9d4519d3ad6f2dcb7e625bbe9b18f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2044/agentshield_0.2.2044_darwin_arm64.tar.gz"
      sha256 "af6a261c43a240c3be792870d2b55354ef16bd8d952f34666940abb0baa79595"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2044/agentshield_0.2.2044_linux_amd64.tar.gz"
      sha256 "39404625a60c041c509c074c8064d1cd36f921153e799b12399ebab320a6e7bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2044/agentshield_0.2.2044_linux_arm64.tar.gz"
      sha256 "d0d1d968e091e858cf5cf3b91124ecf6e480730f577ea302312b67840e88777a"
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
