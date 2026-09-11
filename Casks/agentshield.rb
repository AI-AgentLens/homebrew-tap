cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2116"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2116/agentshield_0.2.2116_darwin_amd64.tar.gz"
      sha256 "ebbab63a0188104488d209b66dacc5862acb8451f7477484c37278f9075c03c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2116/agentshield_0.2.2116_darwin_arm64.tar.gz"
      sha256 "718a3a5b8c2aa0ac711f9e5c38f99b9dcfface52d6521c1c11ec79ccc988ced4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2116/agentshield_0.2.2116_linux_amd64.tar.gz"
      sha256 "fffaa378af03d11663fb5d18b67cd279ccd6f93abb8a296b17fe8bbe801dc4cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2116/agentshield_0.2.2116_linux_arm64.tar.gz"
      sha256 "b22440a80fbdf9179bcefc61d4c2936f680cc383be3e80396a5d2a47cea53e0c"
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
