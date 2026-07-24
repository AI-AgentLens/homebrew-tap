cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1722"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1722/agentshield_0.2.1722_darwin_amd64.tar.gz"
      sha256 "b976f045442ce84b40eeb57c5cdf8ab70d69ce60e308f03b58f0ac470fc036fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1722/agentshield_0.2.1722_darwin_arm64.tar.gz"
      sha256 "569ed12dad1efd07dbd10d8e74130ed5f7ef3e572d2e3b7b6508f18deebdeedf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1722/agentshield_0.2.1722_linux_amd64.tar.gz"
      sha256 "1dcfebb1abc01092042f1f5cfb5441aabc8e36845b09b016ea7dbade8e7e23db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1722/agentshield_0.2.1722_linux_arm64.tar.gz"
      sha256 "2324d22de094168579dac643188f1b22dea6af354f557d0fb7d3190425070970"
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
