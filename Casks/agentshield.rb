cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1531"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1531/agentshield_0.2.1531_darwin_amd64.tar.gz"
      sha256 "2e8f08fc4f57912a0272cb5eb5e914c6b12f79f283bb7d90f417be04924f0ec5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1531/agentshield_0.2.1531_darwin_arm64.tar.gz"
      sha256 "11843ddb8cffae953a3f7668c934f414b36a3aec5006833f47280f19d7d3b818"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1531/agentshield_0.2.1531_linux_amd64.tar.gz"
      sha256 "cdb0e5122a6d9a39b9381e4e09aa4e75e9853b8b4bd24b2a9ff995692154d85f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1531/agentshield_0.2.1531_linux_arm64.tar.gz"
      sha256 "beb5dd004662192d6d83de9fb456f926513285614c2ab215d517698cd9fb2473"
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
