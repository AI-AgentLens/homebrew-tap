cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1705"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1705/agentshield_0.2.1705_darwin_amd64.tar.gz"
      sha256 "4334067818821b22355c04fc051409d68a35a783824a2475f1cc0f13a4bd5905"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1705/agentshield_0.2.1705_darwin_arm64.tar.gz"
      sha256 "1ba908a6ecdffe54cd575256968501e1564ab91d0a7c65de6322b320f9e666a9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1705/agentshield_0.2.1705_linux_amd64.tar.gz"
      sha256 "9c8b7d1b8ecc7f9b0a5bf26faa5c60e9116eb39c5b6e36bf696571f2bb5cb407"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1705/agentshield_0.2.1705_linux_arm64.tar.gz"
      sha256 "77fe49a0af11f84d4000798e892c531e72cbcb1353f796ea5c7920a83e597fe4"
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
