cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.131"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.131/agentshield_0.2.131_darwin_amd64.tar.gz"
      sha256 "661e09cb8115bd2029536a602198bde8925f19fbafc08f8e33b100262f4ea9f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.131/agentshield_0.2.131_darwin_arm64.tar.gz"
      sha256 "2c80a5f856be9dbb8151972518e7027fc92d0101e556500adad813ffbed092d4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.131/agentshield_0.2.131_linux_amd64.tar.gz"
      sha256 "ac80b62e530182a783129dbe915733ac1f444c8c4eba74c23a130110532541d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.131/agentshield_0.2.131_linux_arm64.tar.gz"
      sha256 "602f2aeab39cc2b27dc15f9c09222e123e7e9976c017ba5f3930e3fee670e591"
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
