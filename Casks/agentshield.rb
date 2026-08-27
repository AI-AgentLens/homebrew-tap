cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1964"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1964/agentshield_0.2.1964_darwin_amd64.tar.gz"
      sha256 "1bf8424a3945965723639e367ca65b8b2e146d8b97b45060d772217488a68a83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1964/agentshield_0.2.1964_darwin_arm64.tar.gz"
      sha256 "2b3df47a41309268589946bb4d718112e715cfdc8332fc18a864b7a7e40e7288"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1964/agentshield_0.2.1964_linux_amd64.tar.gz"
      sha256 "4696b80cbeb0ee956e974ee8675c7253d93edcec28c2ab54fe67920313293b9b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1964/agentshield_0.2.1964_linux_arm64.tar.gz"
      sha256 "ae709e7aef25c4c66f763f0fc3ff5acc1fc477d6d9b267ecf7faeffb0ce5cecf"
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
