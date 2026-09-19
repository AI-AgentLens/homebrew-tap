cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2182"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2182/agentshield_0.2.2182_darwin_amd64.tar.gz"
      sha256 "a5a8114bd3fe66e9e5681153494efce903cc7c92c0a497ce51c31241fe3238a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2182/agentshield_0.2.2182_darwin_arm64.tar.gz"
      sha256 "9b9f348273e1156be7eba136f7beb6852ab3ec8e43377f2c6e9ce5270c4960bd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2182/agentshield_0.2.2182_linux_amd64.tar.gz"
      sha256 "764a5f7c0c23987168be5488fb1a92c5b2193b8861c0e1ffc211ababc99c6cad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2182/agentshield_0.2.2182_linux_arm64.tar.gz"
      sha256 "1ff787b52e38ed8c24783fb5a65c469ccb01e34b3d2e70e766f9262015a1e701"
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
