cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2306"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2306/agentshield_0.2.2306_darwin_amd64.tar.gz"
      sha256 "a3bd69ae65729265d2d794ecadfd6627360dd5c1e563abfb60cc55fb94a9db6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2306/agentshield_0.2.2306_darwin_arm64.tar.gz"
      sha256 "fd9796c7c9fedf017a577f200ccdfabc741d5ee13fc8a16adab776bc1dfa5dd0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2306/agentshield_0.2.2306_linux_amd64.tar.gz"
      sha256 "f67553f1c7bd73124bb83278ac01af9e1150e58154dc24b3b1787d7455a3b712"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2306/agentshield_0.2.2306_linux_arm64.tar.gz"
      sha256 "309ed00416cf28985db9c41d2aed86d02cba24507f6407a1429943bf02a75eac"
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
