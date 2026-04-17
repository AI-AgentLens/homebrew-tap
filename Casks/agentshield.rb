cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.629"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.629/agentshield_0.2.629_darwin_amd64.tar.gz"
      sha256 "f9a83efa59c8ea845b2ac5e62628d0ff57bf7fc6e73e921fe0bdf5d94e46d04e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.629/agentshield_0.2.629_darwin_arm64.tar.gz"
      sha256 "40ae48266dd4f5c24927328df80b807f35db59130ce3070d7bfc82f05fef1c0f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.629/agentshield_0.2.629_linux_amd64.tar.gz"
      sha256 "ee4042355fef8d8a9810be3e4dc37eeee1aa3ed8b16453b392d95dcbb88cf751"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.629/agentshield_0.2.629_linux_arm64.tar.gz"
      sha256 "70d250fc660f93968f011a1d47aacfe36708266d48c8577b39e75ad16cee2618"
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
