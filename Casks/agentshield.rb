cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2122"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2122/agentshield_0.2.2122_darwin_amd64.tar.gz"
      sha256 "3d8d63c7a60dc270b6a5897cb0f7e9c26cfb3dc86745de72a66e62c47c3ca493"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2122/agentshield_0.2.2122_darwin_arm64.tar.gz"
      sha256 "89f1efe8420dafc5431e077eb8c64e351f54cfc52ea2fa7572af69f22ea48351"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2122/agentshield_0.2.2122_linux_amd64.tar.gz"
      sha256 "d2f4b3d349713e883132ed0517de3d8f7bcf56d153b0f0a68759ef81363c15f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2122/agentshield_0.2.2122_linux_arm64.tar.gz"
      sha256 "cd13cc2d954d2412da3c5463ecee98680a865ff1c87c6c23bdc802662b810789"
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
