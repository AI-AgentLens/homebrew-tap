cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2518"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2518/agentshield_0.2.2518_darwin_amd64.tar.gz"
      sha256 "6beac2bc1342871fd8b1270ee9be9efb406219c2753e8da85391f801751d491c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2518/agentshield_0.2.2518_darwin_arm64.tar.gz"
      sha256 "651449871d63f63dba9cffa3c4d39cc1af7d5ee7b260048e991002d7e28a8fda"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2518/agentshield_0.2.2518_linux_amd64.tar.gz"
      sha256 "4553a44796bf637898ce74deecab6df7099e4d529f0b9a06de3f3d2c9897d43e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2518/agentshield_0.2.2518_linux_arm64.tar.gz"
      sha256 "de56ccea96a5649431c5f9c7525f19cc2ab35550bdc12f7c4e240943a835dd57"
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
