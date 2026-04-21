cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.674"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.674/agentshield_0.2.674_darwin_amd64.tar.gz"
      sha256 "e5e22ac752d3ed82e53f717ad3151644986a12dec380bb1fc8e25950aef0cd8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.674/agentshield_0.2.674_darwin_arm64.tar.gz"
      sha256 "ffa34dacbdbaa4820175a97ebefa356b1d974f530a648a8b7526bfb5e0b5cd0a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.674/agentshield_0.2.674_linux_amd64.tar.gz"
      sha256 "8beba4e5895cb5cdbc667e7de00136ad84964e6be895e172d65e8837436028ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.674/agentshield_0.2.674_linux_arm64.tar.gz"
      sha256 "f8a26720c62a02b9aeb474758f4d05d791be6f7d6615435955e80899dedfdac9"
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
