cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1296"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1296/agentshield_0.2.1296_darwin_amd64.tar.gz"
      sha256 "2b0c7422f0e61e0afc0e84b299735837170ffee7679d2d795ea540e555eba355"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1296/agentshield_0.2.1296_darwin_arm64.tar.gz"
      sha256 "a815995e9c1fe682135977e8cb87a8745594cd6c94e6f9af95baf2933bd1fc85"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1296/agentshield_0.2.1296_linux_amd64.tar.gz"
      sha256 "b7b9bce35c2d763dd4716e1cb157ba136f0ab84c3d00903dd54633c0635a65d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1296/agentshield_0.2.1296_linux_arm64.tar.gz"
      sha256 "8f0ebeca2548a1e21c895467d4fd85270113a5117c7cdb9c09f3ca8300e0722e"
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
