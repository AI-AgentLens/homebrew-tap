cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.708"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.708/agentshield_0.2.708_darwin_amd64.tar.gz"
      sha256 "1bcc25292aab5a8db6b967bc11fdd760f171eeab36ed4350eb1f750488030acc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.708/agentshield_0.2.708_darwin_arm64.tar.gz"
      sha256 "33b5549eefd0bc2cdd30767b8bde89e5bf92f9689ac8291e5ee7e57fb1561ea4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.708/agentshield_0.2.708_linux_amd64.tar.gz"
      sha256 "109fbd7d92bacee635a7f08664ecc03b941097d5b6af4612f5189158fc6e711f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.708/agentshield_0.2.708_linux_arm64.tar.gz"
      sha256 "1e4f0ed5e22b623d7460f6d163261b1af4687eb22013d35c482577ce808b9937"
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
