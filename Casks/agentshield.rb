cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1263"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1263/agentshield_0.2.1263_darwin_amd64.tar.gz"
      sha256 "e2478a70f03b7adc086d7971320eae6c61414a2c356bd13b5f98c1ec9ab5a3e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1263/agentshield_0.2.1263_darwin_arm64.tar.gz"
      sha256 "9cf749acdcd2e834aaa03c8de203bfda9a7f9ed7f1f131af89761cdca5a3a108"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1263/agentshield_0.2.1263_linux_amd64.tar.gz"
      sha256 "f857c472d4b55523d8f45384eaf2295e481bc8de142044247e629fd9c0e9d498"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1263/agentshield_0.2.1263_linux_arm64.tar.gz"
      sha256 "1687783c55c40a8fca504921158dd0241414bdd6332246c081605bab49176d6b"
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
