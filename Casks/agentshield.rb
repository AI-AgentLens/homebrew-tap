cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.866"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.866/agentshield_0.2.866_darwin_amd64.tar.gz"
      sha256 "f911484fda806562e26cdc73cef072c9dc5b34b7c6f87940a727ebbfbc8b6f8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.866/agentshield_0.2.866_darwin_arm64.tar.gz"
      sha256 "7bcfa1a112c6899310f6742d115449b734d3ec12cf45091b5ef298279714eade"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.866/agentshield_0.2.866_linux_amd64.tar.gz"
      sha256 "fd52243fdce90c7bd67b5ccd1ccdcb1e13c5e60ff308ff605803e13009534256"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.866/agentshield_0.2.866_linux_arm64.tar.gz"
      sha256 "8a21875a92ff37e71313c7451bb437e8578db966282fcb329b396cc3125445ee"
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
