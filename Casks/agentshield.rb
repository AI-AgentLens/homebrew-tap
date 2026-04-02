cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.343"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.343/agentshield_0.2.343_darwin_amd64.tar.gz"
      sha256 "9d1a428a6d5d6709cf3271ab0008b40b79f1188a95e45ae6b3f1eedde3d8529b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.343/agentshield_0.2.343_darwin_arm64.tar.gz"
      sha256 "ae1ef0e674087e7eb089fdba86918325309a7b74eeda801745c45f4d4299d8b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.343/agentshield_0.2.343_linux_amd64.tar.gz"
      sha256 "a6322d1b4177d59ca5f6d5f30cf9fe2f6a33ccb1efd7f413d9e2c869785469cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.343/agentshield_0.2.343_linux_arm64.tar.gz"
      sha256 "ee141f34594f168ca340d25c3e65ae17ac9398d4986a4e967e83339621ac7bf0"
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
