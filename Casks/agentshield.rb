cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1490"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1490/agentshield_0.2.1490_darwin_amd64.tar.gz"
      sha256 "3cf9ee02972303b93c9b9c863c2f5e99276772c1cfa45132a24f08a4d2b4cfc8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1490/agentshield_0.2.1490_darwin_arm64.tar.gz"
      sha256 "963e6f1b45f1bbbcf25444d4878df130e47fd8ae94a1d9edd501584d9999c26c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1490/agentshield_0.2.1490_linux_amd64.tar.gz"
      sha256 "b25b31b026691fbc737ebcf10c49de7e005b11475abbb5ea38d6b5f3a877dbc8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1490/agentshield_0.2.1490_linux_arm64.tar.gz"
      sha256 "a97d181e371a7379cdce90c61c2f50fe62cf239f5d54b1c061e39d6261326833"
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
