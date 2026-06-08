cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1253"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1253/agentshield_0.2.1253_darwin_amd64.tar.gz"
      sha256 "aca2ad53499e6a50d1722a3bdda295aeea05b110f7acd420adb56dfea445843a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1253/agentshield_0.2.1253_darwin_arm64.tar.gz"
      sha256 "33e2f953e511223624ba6e62ebcf13f5c6f976d62b7a6a40b7e1d39b7a2ed814"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1253/agentshield_0.2.1253_linux_amd64.tar.gz"
      sha256 "951acf9510ee614d306f239f20ee4a7ab5ac0681f6aa8d3ef58e21311803905b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1253/agentshield_0.2.1253_linux_arm64.tar.gz"
      sha256 "27d685334dc3f22998cf4fd23175ab172c492045814a9d95837b9df1e7e7dc3f"
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
