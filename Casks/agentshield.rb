cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1362"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1362/agentshield_0.2.1362_darwin_amd64.tar.gz"
      sha256 "735a2e335ff2add2205dfc16afc971c03557a463bda8529a1e5aa886417daa51"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1362/agentshield_0.2.1362_darwin_arm64.tar.gz"
      sha256 "cfcd140b8efc1e8cb6d4b52a455bc9fc67730db3b5a230c72b377b13f8c639a3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1362/agentshield_0.2.1362_linux_amd64.tar.gz"
      sha256 "a0aeb9c34aa4e73168abe74e47e8e5c9a2fe94b692fc257ffa192aeea3babe0e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1362/agentshield_0.2.1362_linux_arm64.tar.gz"
      sha256 "815363677fe867beed689f9f1dc8459b02d28bc1c1d1c7aeee73479f18260020"
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
