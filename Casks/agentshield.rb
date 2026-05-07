cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.902"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.902/agentshield_0.2.902_darwin_amd64.tar.gz"
      sha256 "b5c8ca54b61e9a50402b6773cae86ecdbd6bf0ab68c0a13f3c85734f43afb3fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.902/agentshield_0.2.902_darwin_arm64.tar.gz"
      sha256 "5f19aca80e2d7fcefac71fb250fa099f2849826b0177f70687448538b94d2a67"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.902/agentshield_0.2.902_linux_amd64.tar.gz"
      sha256 "230767f560bd4fd42df014e07afef53915e6ee63e2a94fa8458e5081ba6a8308"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.902/agentshield_0.2.902_linux_arm64.tar.gz"
      sha256 "39269de95eaa36369475f045173289f529acf383d67096008741e214537c270f"
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
