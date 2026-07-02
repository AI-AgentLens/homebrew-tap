cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1533"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1533/agentshield_0.2.1533_darwin_amd64.tar.gz"
      sha256 "2ed223ac79968bed9a20cf3299034b2ff914a1935096bd4a54805dfacf392c05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1533/agentshield_0.2.1533_darwin_arm64.tar.gz"
      sha256 "8f33b8a8d615d26e4493aa61d93cd922ed554168ca3eafd8716a8c1603b1232a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1533/agentshield_0.2.1533_linux_amd64.tar.gz"
      sha256 "0b90a983b2a95726a16f8009ffa242042fa72cb6d44741471a1fead2bdfb7563"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1533/agentshield_0.2.1533_linux_arm64.tar.gz"
      sha256 "9cf4e991c4043f66a5010fd39c1a09310db407c5a20c29fd15ffb8c3366cc925"
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
