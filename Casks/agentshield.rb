cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1824"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1824/agentshield_0.2.1824_darwin_amd64.tar.gz"
      sha256 "6d84a410cc3b90aeac73c7eb7ed50e25968f9c72fd1f2257b6d401821a460baa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1824/agentshield_0.2.1824_darwin_arm64.tar.gz"
      sha256 "b694e588fdc758e0ebd30556e51ad9328219d5b10669b61b07785ad8f1e53ae9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1824/agentshield_0.2.1824_linux_amd64.tar.gz"
      sha256 "db4d365fcc31067b2b40d7b7e4f09f1283c581b85830fcf8a5221e2317709abf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1824/agentshield_0.2.1824_linux_arm64.tar.gz"
      sha256 "0774a5e84d95a69d3312e3ab1f7513d43a31683b890e2abf8f92ee6ab08054a3"
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
