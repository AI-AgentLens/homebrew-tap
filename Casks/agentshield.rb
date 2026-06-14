cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1313"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1313/agentshield_0.2.1313_darwin_amd64.tar.gz"
      sha256 "235b41774cb9c98600c607984684c62af89249677394692e182e20a35b530694"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1313/agentshield_0.2.1313_darwin_arm64.tar.gz"
      sha256 "99ad550a2ad67e3f113feb7784a60284bd6f327f9d719bf7da3a61b4796ec5ec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1313/agentshield_0.2.1313_linux_amd64.tar.gz"
      sha256 "f3844eb50c1e2edf7eab919bf7545914d82965090e3df982c951a6bf1a358738"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1313/agentshield_0.2.1313_linux_arm64.tar.gz"
      sha256 "8cd4d386bc81cacef0f558d78cdab1e6182413fdb3c1e9d2f059f2415021ad61"
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
