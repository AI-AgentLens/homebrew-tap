cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1242"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1242/agentshield_0.2.1242_darwin_amd64.tar.gz"
      sha256 "3d0f37987891faa1ee64fe6b653bdc55a4d189a50cdb5d3ddced94b354296897"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1242/agentshield_0.2.1242_darwin_arm64.tar.gz"
      sha256 "33b7f4a5ca275581435fba858f7157f6b9bdc12ae051558885f8790d2ca03229"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1242/agentshield_0.2.1242_linux_amd64.tar.gz"
      sha256 "384fb165d4d84de74705f7193391cb1c3c8485564e0bc6889631fc5a56cb3d2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1242/agentshield_0.2.1242_linux_arm64.tar.gz"
      sha256 "8b111007f760183dded737900499d45ede8fc5d1953c4f6c8f245c3f2d5aedf6"
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
