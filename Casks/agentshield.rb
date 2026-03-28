cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.161"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.161/agentshield_0.2.161_darwin_amd64.tar.gz"
      sha256 "31f2eaf036ce65b999f3aab43b15da2b93d8ec3363a4e2eb6c6752bda0cdec88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.161/agentshield_0.2.161_darwin_arm64.tar.gz"
      sha256 "2b3d132b80869807ed21e43a5016c198f44caae205f9947d1ad5e1c11d2378ca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.161/agentshield_0.2.161_linux_amd64.tar.gz"
      sha256 "5896ea71a8f334fcd176d8c58dda3bbeaa77ae86554d3b8f338c0660e52de366"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.161/agentshield_0.2.161_linux_arm64.tar.gz"
      sha256 "27cf3e6623a9cf949cc93f7ef37970f5bdcdfd6e5fa482bdcd13d270369edd22"
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
