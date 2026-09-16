cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2160"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2160/agentshield_0.2.2160_darwin_amd64.tar.gz"
      sha256 "2bc22304c42664caa84c228dc191dea936fee2e709d03d15628acac6cf62a45e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2160/agentshield_0.2.2160_darwin_arm64.tar.gz"
      sha256 "136c6f97853127b8fc3d22cec627211e909e1cd205e02284f7d1e78eccf01c3f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2160/agentshield_0.2.2160_linux_amd64.tar.gz"
      sha256 "c817e5b84b08638430550de6718c93ebb007455eddb0db728402a16f9d7eeb57"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2160/agentshield_0.2.2160_linux_arm64.tar.gz"
      sha256 "b5b4c63708075f80c9642c6ed0421d800da53d538edc0596c8395bd7ca662147"
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
