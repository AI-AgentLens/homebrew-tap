cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2248"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2248/agentshield_0.2.2248_darwin_amd64.tar.gz"
      sha256 "2ac555ddf8a973715b2735ea6ea227fe9f0b3a4eff3c58225a8f8f5bc68f5077"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2248/agentshield_0.2.2248_darwin_arm64.tar.gz"
      sha256 "6e5c62a8e7edfc6d513a0cd4d1a72f28d879017588487788a88277061273937b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2248/agentshield_0.2.2248_linux_amd64.tar.gz"
      sha256 "e43026c12142af753f65a71f5103605570b1acc5743cd073af02c0b638f44dc3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2248/agentshield_0.2.2248_linux_arm64.tar.gz"
      sha256 "ff02eb203d2fba7e5a463bbaf35e468f7a3e867ef63d422713ac60c42f53bcad"
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
