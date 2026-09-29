cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2286"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2286/agentshield_0.2.2286_darwin_amd64.tar.gz"
      sha256 "7f54fc88f806c53f264615fff1ee4cf5b3f064c7b91043963150c9b801a22ec7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2286/agentshield_0.2.2286_darwin_arm64.tar.gz"
      sha256 "0f42903b2d6f1c86363a2d398533f785d3590360b2ccaa385282c5ff983187a1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2286/agentshield_0.2.2286_linux_amd64.tar.gz"
      sha256 "ec4622282e933070f81828f46f54203f31ac0afcf1a3a4e83bb4d1fd71edd156"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2286/agentshield_0.2.2286_linux_arm64.tar.gz"
      sha256 "7d4e66206ec75484a65bd669d93feb8f18bde0a9b94e42b81d7c46d5460e917d"
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
