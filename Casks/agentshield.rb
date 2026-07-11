cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1620"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1620/agentshield_0.2.1620_darwin_amd64.tar.gz"
      sha256 "ce438e9b0800fa12b3eb4a3462748cf6836af45e383368439dd611f31d7e7b89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1620/agentshield_0.2.1620_darwin_arm64.tar.gz"
      sha256 "5cd5b4e405c322b56600cc80d178a735a0516aad6dcb3a3d7bbaf62dfa13ea96"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1620/agentshield_0.2.1620_linux_amd64.tar.gz"
      sha256 "ebb3e9dc91ea2b989f1da3d5c45e2293fda6dbb0d0f5d61726ffa2fab378751c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1620/agentshield_0.2.1620_linux_arm64.tar.gz"
      sha256 "f8727722bd56513ee5bd1057d01272937daae79d931949157d31c685a50e7547"
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
