cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.761"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.761/agentshield_0.2.761_darwin_amd64.tar.gz"
      sha256 "d11d78d1fb86cd81e6ce097929c8520e3f7810f1c08b356adb6c06161de703d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.761/agentshield_0.2.761_darwin_arm64.tar.gz"
      sha256 "058424e378876452e12aed858d466aaabfb942e1a934a8bdfbd2a5e988d6a57d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.761/agentshield_0.2.761_linux_amd64.tar.gz"
      sha256 "202c40a74827ff2b57910d27d86ed3bafd06c84639085620564415fb8b5bd4aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.761/agentshield_0.2.761_linux_arm64.tar.gz"
      sha256 "c922417c50026f340670947f724f75f529c4d5b812ca7924eb4abaf17468bf46"
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
