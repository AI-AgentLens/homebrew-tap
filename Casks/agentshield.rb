cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1791"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1791/agentshield_0.2.1791_darwin_amd64.tar.gz"
      sha256 "0f5f2fd7955ec5eecdce5f648e0b44c6c796ce721ab5f44b6ee2eb2f848eb6b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1791/agentshield_0.2.1791_darwin_arm64.tar.gz"
      sha256 "3e10ee7eda69a83480ffb3f42956757109fada188ea8c14b1e729b38e24f4476"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1791/agentshield_0.2.1791_linux_amd64.tar.gz"
      sha256 "4b8186708f66cfeb0691a7c22c1196dbd2150b0dd368274b34d16602f832547e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1791/agentshield_0.2.1791_linux_arm64.tar.gz"
      sha256 "3bf5cb30b881afdfd22391ee78e2b98052a1a5d0aee47b9f5ee3f41805839c28"
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
