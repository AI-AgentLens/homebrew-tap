cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.741"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.741/agentshield_0.2.741_darwin_amd64.tar.gz"
      sha256 "b566124fb416c88171c4b3ac46f590f447f9ce1c0dda4466bb492d014e8eac99"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.741/agentshield_0.2.741_darwin_arm64.tar.gz"
      sha256 "275750adf9e6ce9b36e43c1a5511b8eebb26d133d1414ae3849365a6ff334e8c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.741/agentshield_0.2.741_linux_amd64.tar.gz"
      sha256 "16642158387a29beba913c0de091064cdfce9588270fd82b6f3d2efbee64ee7c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.741/agentshield_0.2.741_linux_arm64.tar.gz"
      sha256 "eb7a887beac6fb7653897a16a312e86023a356fcdb35095c424a1abf47576302"
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
