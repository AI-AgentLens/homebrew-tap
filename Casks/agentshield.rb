cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1183"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1183/agentshield_0.2.1183_darwin_amd64.tar.gz"
      sha256 "b2ea5bbb766e73b6cec5f03aff3df6e9bc5b0f9bd864ebfd8bd3d4a167f2b70d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1183/agentshield_0.2.1183_darwin_arm64.tar.gz"
      sha256 "d5f28d9ac3010180d41cfe2882f76a963f0744203cc3242d67c97c334cb4af9a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1183/agentshield_0.2.1183_linux_amd64.tar.gz"
      sha256 "dde29eeeb1d6f6b8864c245a95d74921b54ff0909891582ea7a045857b145d53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1183/agentshield_0.2.1183_linux_arm64.tar.gz"
      sha256 "071b7d335d25b14040eac053a48143d9b4e0323a0fc58dcc917eda91fd77a0fe"
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
