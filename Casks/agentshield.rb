cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.274"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.274/agentshield_0.2.274_darwin_amd64.tar.gz"
      sha256 "78d8df0abfa8251bfeb07e7a543cdfa2dc80c3975094fc0dd1e013f13b12fabb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.274/agentshield_0.2.274_darwin_arm64.tar.gz"
      sha256 "1b429f449a1051782bbcafe49e399b5dd1a3a7c7a7482e1f2a8a8138b7b859c3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.274/agentshield_0.2.274_linux_amd64.tar.gz"
      sha256 "0b7766f41f489115a308ae78e165c445fbfb4effb55a0ca13b0ebd63abf80b9b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.274/agentshield_0.2.274_linux_arm64.tar.gz"
      sha256 "6bb5a7086afdec7c5d4518bd09bbe9c79c23eb5bfd177e6989278277fc1c822a"
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
