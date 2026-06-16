cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1326"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1326/agentshield_0.2.1326_darwin_amd64.tar.gz"
      sha256 "f71ce0b6676a16ac6e7dc64c1dd39784c7dc2d2db744c188dcc4dc9c969405ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1326/agentshield_0.2.1326_darwin_arm64.tar.gz"
      sha256 "b3d67c08aa71effc9e580a40dae7441e6d6c0fcf2bd5a73b33ac0b52769a8523"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1326/agentshield_0.2.1326_linux_amd64.tar.gz"
      sha256 "bef0863de78147a5d1d6d2b84b2308238f6ee2e2d110446ad27e24b487b92d5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1326/agentshield_0.2.1326_linux_arm64.tar.gz"
      sha256 "bd0432ea5fd5846db7a9930a42001604dd768afd466b3b7b96bd28e4e102a074"
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
