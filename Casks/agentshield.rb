cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.646"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.646/agentshield_0.2.646_darwin_amd64.tar.gz"
      sha256 "e7bf4795b8008bea4fa37777f69dd6ea4c93bcbd8ae1a6d59f0c3e7899aba413"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.646/agentshield_0.2.646_darwin_arm64.tar.gz"
      sha256 "1f4802b595d34e53e842c709f65ef2c30403331ca612ffe8a6a78261f33f78c9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.646/agentshield_0.2.646_linux_amd64.tar.gz"
      sha256 "0216d43f3776947446568fa281f34a6f20750803e42671132459d896b9da84c1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.646/agentshield_0.2.646_linux_arm64.tar.gz"
      sha256 "fdb0525de209f1d6d97e82f67b744eb2b2b3031899caef18862eae48b01c4500"
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
