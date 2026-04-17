cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.631"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.631/agentshield_0.2.631_darwin_amd64.tar.gz"
      sha256 "32f3ff948e063cbcd8494016eec8c4dabbb791c4cba1bd3d98c53f47251685ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.631/agentshield_0.2.631_darwin_arm64.tar.gz"
      sha256 "67cc029aa67b5497d5a2e7187d03524014371744158e3ccdb5f84f8adaf57040"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.631/agentshield_0.2.631_linux_amd64.tar.gz"
      sha256 "a54936f896a0858520958c0e35db1688ce834705d05565a9474f862db55466c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.631/agentshield_0.2.631_linux_arm64.tar.gz"
      sha256 "a859f9b48ad58cc58b0fab27929f19fbc7877a4fec350608882bd74d092954c1"
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
