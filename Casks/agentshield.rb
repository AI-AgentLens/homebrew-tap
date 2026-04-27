cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.778"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.778/agentshield_0.2.778_darwin_amd64.tar.gz"
      sha256 "00073ca7764bf9997944f36a8d814a04364df2fdc6273f7d04508ba3f031366f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.778/agentshield_0.2.778_darwin_arm64.tar.gz"
      sha256 "d4efcaa33164acedcd59861460af903d51aa3c17f5485e4edb5f1270bee3cca5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.778/agentshield_0.2.778_linux_amd64.tar.gz"
      sha256 "912580a6a2e66be23b24db2b5607f1f0b46070d11de0fd55031eb120ab759549"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.778/agentshield_0.2.778_linux_arm64.tar.gz"
      sha256 "a21ffb0fdd4bca3e87b354f684874beae0800ba008979ec2c7447c2508ff84ba"
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
