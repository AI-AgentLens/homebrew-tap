cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.724"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.724/agentshield_0.2.724_darwin_amd64.tar.gz"
      sha256 "4df82c2f344b3988cc0005df984f3fb642cd5d923c59abd03e1d6d8798640f0a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.724/agentshield_0.2.724_darwin_arm64.tar.gz"
      sha256 "0eda9b58584f623992be06e7dfd8280d287c8e372f9da3e5d31519efbe408888"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.724/agentshield_0.2.724_linux_amd64.tar.gz"
      sha256 "8c10ae1dc7caeb79964d024e71cccadda5eae08a6479fbd26b9c98d6d2e6f6ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.724/agentshield_0.2.724_linux_arm64.tar.gz"
      sha256 "0d503901ea1bae887cff4d5991830da0d530864467ef0577cd610eb74f00c482"
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
