cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1942"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1942/agentshield_0.2.1942_darwin_amd64.tar.gz"
      sha256 "10283a1699a007361b6861d1f35d074628d4e1989998cf481baf6fbdec04f95e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1942/agentshield_0.2.1942_darwin_arm64.tar.gz"
      sha256 "19d0daaa700c62e54bf4913b3c76b079a810d35bef3cce061e93299721bf08d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1942/agentshield_0.2.1942_linux_amd64.tar.gz"
      sha256 "f511539867f71f086071a8cb5249ceb7e70f1eebabc6346789c092244e9c8271"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1942/agentshield_0.2.1942_linux_arm64.tar.gz"
      sha256 "0a603230971758f9a7a870aca071c497a7042ac904a2ff37ba59ee690451bf5c"
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
