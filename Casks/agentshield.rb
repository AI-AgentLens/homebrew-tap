cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1039"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1039/agentshield_0.2.1039_darwin_amd64.tar.gz"
      sha256 "63744d1512cd85c0f2bcfc8fc1a8f86236a691bcb9fd5e71fe4cdc0356ab3c8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1039/agentshield_0.2.1039_darwin_arm64.tar.gz"
      sha256 "c8b7107cb62af7c23ec661e6541c3fd18922d7359fde1e5b7c3aeba3350abd8c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1039/agentshield_0.2.1039_linux_amd64.tar.gz"
      sha256 "8c6f53a0fef5943c34772d8baaa2f97ae723760dcc6c618ff81e57d1f3f4ca86"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1039/agentshield_0.2.1039_linux_arm64.tar.gz"
      sha256 "fa055c88dfdce30d938f970a4e3f55cd124024158749dab1ce9e586377fc4623"
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
