cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.510"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.510/agentshield_0.2.510_darwin_amd64.tar.gz"
      sha256 "76aff4c0ab30f8da9aa7b22cdd9c9b9c4889628c99b506d06e956c71e5ddb093"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.510/agentshield_0.2.510_darwin_arm64.tar.gz"
      sha256 "bc1e39a6ec15c98508947930f0869a956db2ff57ed1849a86700fea81d9104c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.510/agentshield_0.2.510_linux_amd64.tar.gz"
      sha256 "1d2190971b1ef46d8ea2d094bf7d589202bae5c4342a9c40a1533ea39343355e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.510/agentshield_0.2.510_linux_arm64.tar.gz"
      sha256 "f57d591ac1460fbc053f1e645a57b05362327c5a3371ac3ce066336fe08c0f31"
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
