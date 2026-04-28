cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.802"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.802/agentshield_0.2.802_darwin_amd64.tar.gz"
      sha256 "56207b3ef2bf4f1322725aa255b8ca4d1d6b35cc278fd4dbaab1e6890bed64c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.802/agentshield_0.2.802_darwin_arm64.tar.gz"
      sha256 "9c4290c13ba7f4bb53f9e89e9a6f700690f66d97b9d7729cf6e074fe1d74bbc9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.802/agentshield_0.2.802_linux_amd64.tar.gz"
      sha256 "ee8d56c2af28ec15312675c772d2dfb6fa20d978fe5097b89ce8a73661ad6948"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.802/agentshield_0.2.802_linux_arm64.tar.gz"
      sha256 "dedd8139d95ca079db6d9e7ecc887b461fcaeca088d5af404c8298d816febcd6"
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
