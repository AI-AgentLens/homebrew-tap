cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1470"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1470/agentshield_0.2.1470_darwin_amd64.tar.gz"
      sha256 "33acb54ccb5c6b9be2fcafa903e2d4724bf21b51a9f3f8c1a415feb41a56ddb2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1470/agentshield_0.2.1470_darwin_arm64.tar.gz"
      sha256 "8803e6892cc1986dd82ecc07de3cde6f8b7d6c82882dbbb65bc0cecd35695a46"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1470/agentshield_0.2.1470_linux_amd64.tar.gz"
      sha256 "79e027b7abaf48502cba8d9a79fcab4df726860c1dcc9e0c71a155f9196c0203"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1470/agentshield_0.2.1470_linux_arm64.tar.gz"
      sha256 "d6c7580bd1730ceab35cf5d30cb050f54034cb75f18c63df4eb1cecc46b2d3a5"
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
