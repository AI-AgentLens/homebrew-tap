cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.349"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.349/agentshield_0.2.349_darwin_amd64.tar.gz"
      sha256 "2368b0dfe982b6a7c015f24ee9cafa263615cc0ccf44b6307201866512106243"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.349/agentshield_0.2.349_darwin_arm64.tar.gz"
      sha256 "5d7ee1382b4a6bca8d5019d166bb706f00b25541097f9f6b4ca6d798d29702a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.349/agentshield_0.2.349_linux_amd64.tar.gz"
      sha256 "9150a3974085ccb74ee711b40718fd35750e8c96a58052dc92e5f44eb0f35f7c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.349/agentshield_0.2.349_linux_arm64.tar.gz"
      sha256 "45d03357bfb4bba10e45522edc297d490d63874478ec95dce8dfc0def8c55c32"
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
