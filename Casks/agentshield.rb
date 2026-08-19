cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1901"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1901/agentshield_0.2.1901_darwin_amd64.tar.gz"
      sha256 "bf8855eab2e7981a34f060e0ee745c6817fe934e5f1968f832d83198623e08e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1901/agentshield_0.2.1901_darwin_arm64.tar.gz"
      sha256 "695f345ffe43a96889c1b10093e1bc414546609c0bfc63eb972247c9202fda87"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1901/agentshield_0.2.1901_linux_amd64.tar.gz"
      sha256 "b6e4cb921119c8f2965d86a2a4a380989b65aef364c131b2f911d20b526857a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1901/agentshield_0.2.1901_linux_arm64.tar.gz"
      sha256 "040c8fb67a500fec10aebc15632929c8ce6461e75aa6199cf93bf75b896f4e40"
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
