cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1578"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1578/agentshield_0.2.1578_darwin_amd64.tar.gz"
      sha256 "9f0df190a3efac8cef9ba653adc09bbae53674e04349c6e2b7bfbb9d7e735ff4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1578/agentshield_0.2.1578_darwin_arm64.tar.gz"
      sha256 "bc7d52ab5749fd8c215830e08068ca4b9bdb100ea8114c2b5a1bd2fed6510a58"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1578/agentshield_0.2.1578_linux_amd64.tar.gz"
      sha256 "fa6db2bc30e2529a8d9c7b6db7ac6637111a028eda033be561885cfcb4f52087"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1578/agentshield_0.2.1578_linux_arm64.tar.gz"
      sha256 "e618a7112251fa71c16241764db4884bdb047dec30d18f945164f69bf3f61c4b"
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
