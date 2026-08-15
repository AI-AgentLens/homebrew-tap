cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1861"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1861/agentshield_0.2.1861_darwin_amd64.tar.gz"
      sha256 "825fe42d546417652bfdbc32b9bde9a2d128e827750ac0a3d8a2ffacb31ce454"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1861/agentshield_0.2.1861_darwin_arm64.tar.gz"
      sha256 "e4ef62c6f0ec4c6f3c39dae1204f0af4ee40bc676519f38230586e7e315a194e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1861/agentshield_0.2.1861_linux_amd64.tar.gz"
      sha256 "78c737474a94c433b4c89246ab73bfe80ba613f5440f6c7053d7c490f865bbb3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1861/agentshield_0.2.1861_linux_arm64.tar.gz"
      sha256 "b0375d49eb817aa892cd99aff59cce292dde5cee58cde590eb4dfb56169222c2"
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
