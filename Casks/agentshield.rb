cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2294"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2294/agentshield_0.2.2294_darwin_amd64.tar.gz"
      sha256 "c31e38a5e397bb73e8de3f4b630365609c0b282efdd5e49621e561e41007c714"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2294/agentshield_0.2.2294_darwin_arm64.tar.gz"
      sha256 "0e10696eea7389540ef2e2e2a9203030781a31e7d20e1c9e593d10255bfb1ae7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2294/agentshield_0.2.2294_linux_amd64.tar.gz"
      sha256 "03e5adb93cc213062ee431aa2138dea12f1920d4f18262a8b8c9b0e6cfe332c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2294/agentshield_0.2.2294_linux_arm64.tar.gz"
      sha256 "5db9856a3a9d7f5a9741260487ca913c34af4777dcf91de69e81f6ee65cb8b6e"
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
