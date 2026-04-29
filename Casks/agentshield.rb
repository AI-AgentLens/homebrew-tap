cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.807"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.807/agentshield_0.2.807_darwin_amd64.tar.gz"
      sha256 "3e6f1defc2e03fed4bdee0961fd6c695a5578b5d11b70f83046cd6e975066703"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.807/agentshield_0.2.807_darwin_arm64.tar.gz"
      sha256 "285201f31ac8d1bd44515ac73c72704eecdaf7f6b35dc4115248a193837ab38a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.807/agentshield_0.2.807_linux_amd64.tar.gz"
      sha256 "e3a881d38a01c848238046e0fe9db58a66cdf2a6520415a7a9e9dcaa3dcd49e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.807/agentshield_0.2.807_linux_arm64.tar.gz"
      sha256 "dfe6c81dd262f80ac291e41220b66d9af54337bd8e10aad5d572f33a7296dd76"
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
