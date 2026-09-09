cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2098"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2098/agentshield_0.2.2098_darwin_amd64.tar.gz"
      sha256 "8c1d93dc89cdc962d6e5c16f1b6cf4e63e354b654c7ae408c17f17eaa2ecbce1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2098/agentshield_0.2.2098_darwin_arm64.tar.gz"
      sha256 "904ccffd040f83feb185e3ab54412290243fbf1bb1b412acf5cdcdff762eb427"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2098/agentshield_0.2.2098_linux_amd64.tar.gz"
      sha256 "71e646fc21e9425d5a98c7c12c81e8a5cae9b23bbc9eb01fd8f641cf780625d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2098/agentshield_0.2.2098_linux_arm64.tar.gz"
      sha256 "1ebd785ce76228ab00cc0426c17367739400cdd38e50a8d4cc2ce02c7f803dd8"
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
