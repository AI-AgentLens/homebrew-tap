cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.243"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.243/agentshield_0.2.243_darwin_amd64.tar.gz"
      sha256 "13e65665dd5566c657bd7f42f0f4aed0566ae916e8fb1af801053e0381156deb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.243/agentshield_0.2.243_darwin_arm64.tar.gz"
      sha256 "f8ab0fb3d2422c437c6d86f95ef18cf7ad84159efee469c89cbb259f8ba07176"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.243/agentshield_0.2.243_linux_amd64.tar.gz"
      sha256 "82d5bca1fb093a9c834bf496e097ddfdd05f57197cf9c866d70f8c04b173cc4f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.243/agentshield_0.2.243_linux_arm64.tar.gz"
      sha256 "42a31e4f2292f9b8f680ebe4c3e73269b403ba9ab5b4c44492d5ac8fa10a39ba"
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
