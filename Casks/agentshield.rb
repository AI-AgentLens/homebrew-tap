cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.442"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.442/agentshield_0.2.442_darwin_amd64.tar.gz"
      sha256 "9006b8cc9ec926806e28b89dd183cdb99c560044b615bb59113a3698fa2a2e21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.442/agentshield_0.2.442_darwin_arm64.tar.gz"
      sha256 "8ae1d008fc32a3d8dde5f1219ec1934bf734f7d40cc9d691c4962047e0139989"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.442/agentshield_0.2.442_linux_amd64.tar.gz"
      sha256 "7b64cf110983547b07433a7b7aab1a8750b6df71c2cab629083acca44855f3b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.442/agentshield_0.2.442_linux_arm64.tar.gz"
      sha256 "281b7368669f791b7369b5d153083e66748b0d197f4b26a6e92ddcdb187e96c4"
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
