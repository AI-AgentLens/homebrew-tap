cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.188"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.188/agentshield_0.2.188_darwin_amd64.tar.gz"
      sha256 "b807fcb4aaaeecc5474cb7235e346f0e438d0ec1b4991d7fe5a463c7094db729"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.188/agentshield_0.2.188_darwin_arm64.tar.gz"
      sha256 "88c8b0ea93fe7c0f5356280c231837a0df9ad2b1e07fa58770a0ecac36a28d18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.188/agentshield_0.2.188_linux_amd64.tar.gz"
      sha256 "7d60621a2bd2518327204a407c5d28f01e0aedf65e1ef259676e16bc5cc8e74c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.188/agentshield_0.2.188_linux_arm64.tar.gz"
      sha256 "941302a67b3d0084c675cc3ef5f636aa8355e6c185697209a02872f627d7e086"
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
