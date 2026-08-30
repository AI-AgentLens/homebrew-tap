cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1993"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1993/agentshield_0.2.1993_darwin_amd64.tar.gz"
      sha256 "abb58c633ff4c25ebd29cd10a395b9c501c13f02261da920411fca61f8b3f518"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1993/agentshield_0.2.1993_darwin_arm64.tar.gz"
      sha256 "d9b0558bc35d0c28137298bb6c7ba8f3672d58865d7e4554100c115c6091123b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1993/agentshield_0.2.1993_linux_amd64.tar.gz"
      sha256 "f9c0a1c432af522bf66aafa8fabd389bcf7ccdbd0ecd0f80cef26c814f71bff9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1993/agentshield_0.2.1993_linux_arm64.tar.gz"
      sha256 "9c2fcb2cd31f53f4a7062e4fbb462f3ec16e84fb64881890a8b71fede07c7184"
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
