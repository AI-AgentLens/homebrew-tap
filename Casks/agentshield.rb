cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.529"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.529/agentshield_0.2.529_darwin_amd64.tar.gz"
      sha256 "640ea961162aad3535ae28b59b1b90a1025f53a11817cd74116a7167fcfa71b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.529/agentshield_0.2.529_darwin_arm64.tar.gz"
      sha256 "09a386e0f095bb17ad7fb3e43d78c0505ccf10171cc0920941a2056336b37c8f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.529/agentshield_0.2.529_linux_amd64.tar.gz"
      sha256 "f395264f7b0d6eb928617e6df4153194b4d0c0f52583ae1145b2ca30f2e1d924"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.529/agentshield_0.2.529_linux_arm64.tar.gz"
      sha256 "43f12d2451929bda1433c83f141e956cd8147669fcebd8a17e3d108b8656cffb"
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
