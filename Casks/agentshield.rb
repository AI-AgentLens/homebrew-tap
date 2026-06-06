cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1221"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1221/agentshield_0.2.1221_darwin_amd64.tar.gz"
      sha256 "9ad872e0d8fa9a47781a23a618ef38369aab1dda3aad6e9299645e8cb106561a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1221/agentshield_0.2.1221_darwin_arm64.tar.gz"
      sha256 "3c64eee07e1117ed087913cd3da7f51313cff22d023c2f1222e870ae63ebf1ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1221/agentshield_0.2.1221_linux_amd64.tar.gz"
      sha256 "a5735e649ffdb8d8f6ceceba6e3896478f01d894cd3f2d7339b6ed1c0954cb2d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1221/agentshield_0.2.1221_linux_arm64.tar.gz"
      sha256 "4e54bc8eaf34bbd49b921ec888803b7eba043b7ad7865f6a4f934f66ea67e626"
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
