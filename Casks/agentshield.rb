cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.821"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.821/agentshield_0.2.821_darwin_amd64.tar.gz"
      sha256 "1780415f70411342d91b8b1a5654f9772345e2e299997441ee7e2790e83eb1d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.821/agentshield_0.2.821_darwin_arm64.tar.gz"
      sha256 "fe2300999c0c115fb6ff603e6e1846c504ecafba57a245374a71451ed38b0dec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.821/agentshield_0.2.821_linux_amd64.tar.gz"
      sha256 "744f2e0faa15a6fa28b506730512efff6761e348bf6025764cddafb770713b73"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.821/agentshield_0.2.821_linux_arm64.tar.gz"
      sha256 "80eb0bd6bb7f4b14de388b4320477b81af321ab1328da693f70d2f07677efca2"
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
