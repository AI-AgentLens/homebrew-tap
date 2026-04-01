cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.278"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.278/agentshield_0.2.278_darwin_amd64.tar.gz"
      sha256 "dee30f5f83e9cf37457829143f2eb582dafff3caf7d1a624e37cdc48fa28be97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.278/agentshield_0.2.278_darwin_arm64.tar.gz"
      sha256 "2cd87025e31ea7db35a2bc687ce85c1deaa8868be3cbf3cb0736395bc1a770e5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.278/agentshield_0.2.278_linux_amd64.tar.gz"
      sha256 "a4039c27e0c2ccdb36a47e23e2ecb502afd39c97af802ba0a3cde8fe32a18a03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.278/agentshield_0.2.278_linux_arm64.tar.gz"
      sha256 "a1b242367c24dc0147682a3917bd3f455bda5e716f0345b77a408f15d938a9fd"
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
