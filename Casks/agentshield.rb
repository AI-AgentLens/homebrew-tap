cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1685"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1685/agentshield_0.2.1685_darwin_amd64.tar.gz"
      sha256 "8616c6e6ce39b3c8170d57bd097eb848376d11fee4a786fff2a6b87e67444b6f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1685/agentshield_0.2.1685_darwin_arm64.tar.gz"
      sha256 "e22db63ccf0d42783afe4e5feded181e8c611213f8d21577c8c2d4b2cd1e7f6a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1685/agentshield_0.2.1685_linux_amd64.tar.gz"
      sha256 "83d21773e215e088431e7161e94c6a131bfefa80455f7739d88abaf6d9bc5b5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1685/agentshield_0.2.1685_linux_arm64.tar.gz"
      sha256 "edbaf4d891b757d89691a3670748ef2d013d7eed260cb8e978d795a9dd260667"
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
