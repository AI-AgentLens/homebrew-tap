cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2141"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2141/agentshield_0.2.2141_darwin_amd64.tar.gz"
      sha256 "0d530fe1d807874db61252ff96c1dfa84506e8fe80977eccdcb49fb0e47d3278"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2141/agentshield_0.2.2141_darwin_arm64.tar.gz"
      sha256 "a2476534187363556a307c81952fac3e2825a5f3e8720affa11ea07c81e599d6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2141/agentshield_0.2.2141_linux_amd64.tar.gz"
      sha256 "4d31609a54aeb343b2b304ec5c4c557d68ce25a865254b94a1119a43427b8e0a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2141/agentshield_0.2.2141_linux_arm64.tar.gz"
      sha256 "43553f694000ba4eccaa7f9dafc289e1e037eb33541642ef3d6c6eecdc09bcdc"
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
