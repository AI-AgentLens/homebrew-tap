cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1114"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1114/agentshield_0.2.1114_darwin_amd64.tar.gz"
      sha256 "e831ad3a389ac85ea4ebb0758c0ed454ffe6fd44b7802997880f91cbe27dac76"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1114/agentshield_0.2.1114_darwin_arm64.tar.gz"
      sha256 "5400a835be7840561ec4b843a728af187f47a2dffc31b843c4839154cf07e3a7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1114/agentshield_0.2.1114_linux_amd64.tar.gz"
      sha256 "2748527d787fdc4ae4736c75de5ed5a2e35009da7454b89498b16453a471761d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1114/agentshield_0.2.1114_linux_arm64.tar.gz"
      sha256 "7458ca7868709ec4e8a3fb7338f37fa960d0c2f4e3673f34545abee87e4dfe48"
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
