cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1516"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1516/agentshield_0.2.1516_darwin_amd64.tar.gz"
      sha256 "788883e142f33620f3bdcdf59dc956be73528a329a3b367af214c090d977c82a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1516/agentshield_0.2.1516_darwin_arm64.tar.gz"
      sha256 "dc411c47dd5a497f519387bc4136e84fdfc173045d69c46fbeeae811b6c037b0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1516/agentshield_0.2.1516_linux_amd64.tar.gz"
      sha256 "eb3fc364592163b8b047ddef4b1f7051ae223f46c10a6c83fd7cafb03aa32846"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1516/agentshield_0.2.1516_linux_arm64.tar.gz"
      sha256 "935aea794a313c7b26a0c7dd4a57cb3f855cee3e6a31319cf70915bd34e4f3ca"
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
