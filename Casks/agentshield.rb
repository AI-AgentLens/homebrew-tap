cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.617"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.617/agentshield_0.2.617_darwin_amd64.tar.gz"
      sha256 "0a1e84745ab4de32de71276af5f752a7e00de989e65d25325dfc3a919979abd7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.617/agentshield_0.2.617_darwin_arm64.tar.gz"
      sha256 "6c10264a06612a7c50013df61a0a64ad61630f19a197040147c3230d24593c88"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.617/agentshield_0.2.617_linux_amd64.tar.gz"
      sha256 "ace89a4a0b0a54c13556806057e925fbdf5b2855d01c3f9e58a88a5f359f2fcd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.617/agentshield_0.2.617_linux_arm64.tar.gz"
      sha256 "25e3ba94d1d7aad24365702fb62b4c624e77965a11aca7673798ebe22b54af49"
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
