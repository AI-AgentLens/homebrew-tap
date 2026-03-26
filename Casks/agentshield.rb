cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.84"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.84/agentshield_0.2.84_darwin_amd64.tar.gz"
      sha256 "e6dfec887413d76ae8a344b38e2e3b9efca1149e2f51b39796f45b91669681f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.84/agentshield_0.2.84_darwin_arm64.tar.gz"
      sha256 "451087ac2ea971644c5418bcb1de4e4f4aee7596886125301f9e82a62c013c2e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.84/agentshield_0.2.84_linux_amd64.tar.gz"
      sha256 "a51171276c3bea812c28f42d2169f3b31a76789ceb05164c21ba6bf4105bac81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.84/agentshield_0.2.84_linux_arm64.tar.gz"
      sha256 "aff1c49ae9f80f298a41aa1a3ea416fcbc7f2c8f3de271740d5071b8a1582cd8"
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
