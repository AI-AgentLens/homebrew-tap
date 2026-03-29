cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.181"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.181/agentshield_0.2.181_darwin_amd64.tar.gz"
      sha256 "d8aa6bb55d5e2027c22e50641e5776e63e44264712bd88b497940c0ea332e08e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.181/agentshield_0.2.181_darwin_arm64.tar.gz"
      sha256 "da48d62485f2384761810fef73ea7c2a889e83937931c2bb1f77aab77d2f7daa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.181/agentshield_0.2.181_linux_amd64.tar.gz"
      sha256 "c067f1200caafd3a7383efebb5139af9291183870bfe7f5cb153efae9181eec6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.181/agentshield_0.2.181_linux_arm64.tar.gz"
      sha256 "445c6e132c1ce6fd849b48be12fc5f94920c652a68a7df54dbeaee8e6dee21ef"
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
