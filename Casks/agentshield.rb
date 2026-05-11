cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.949"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.949/agentshield_0.2.949_darwin_amd64.tar.gz"
      sha256 "b90f1fa968e86c86a4878404788302fcd64f9b8352ebcc3d90ea303616da5766"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.949/agentshield_0.2.949_darwin_arm64.tar.gz"
      sha256 "5a24f045305d903ced2c4905efbad4ad27d2a58da9a9e90225134400a845ae7f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.949/agentshield_0.2.949_linux_amd64.tar.gz"
      sha256 "d9e637785036459d8ad3b5e531ee18df33254269006defd78e283348cbea3df9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.949/agentshield_0.2.949_linux_arm64.tar.gz"
      sha256 "38904980fd7d431f6d2d36445df5df3d111b285178467f18462a370c9dcb759c"
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
