cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1544"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1544/agentshield_0.2.1544_darwin_amd64.tar.gz"
      sha256 "aa6a0eacd5197a182b41804ac38d88c3056f9e49b95e031f4f6b5ab6cd8a290b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1544/agentshield_0.2.1544_darwin_arm64.tar.gz"
      sha256 "7673f93f45beddc5d91a0dfb6015bcef0278d9d0e8ec0d66e028ea56c87a827d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1544/agentshield_0.2.1544_linux_amd64.tar.gz"
      sha256 "1b348f4bf69f8ab6e71fda1600780d5a60f3131e239edc1e388af8de77c23cec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1544/agentshield_0.2.1544_linux_arm64.tar.gz"
      sha256 "e68395a4a1e755b44375e813a783a4db165463cc21745d3cc06dec371488ca30"
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
