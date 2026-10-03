cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2326"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2326/agentshield_0.2.2326_darwin_amd64.tar.gz"
      sha256 "1132ab3a8a6d2c8543398ed0389dd07a19a609b646e03e94f1bc240d30589b90"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2326/agentshield_0.2.2326_darwin_arm64.tar.gz"
      sha256 "44b747de6b830a88bb6016155b1b9701314adb7f2293b66d235e663d3fd00933"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2326/agentshield_0.2.2326_linux_amd64.tar.gz"
      sha256 "a6fadea18f74712ec84de09cf3464cc40929df39333ff4669de413fb185da8d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2326/agentshield_0.2.2326_linux_arm64.tar.gz"
      sha256 "95b4d9c379e3189f0d59a9d63d4d5dd8d01be456be4af86c4ed459977e590852"
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
