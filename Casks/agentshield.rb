cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1017"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1017/agentshield_0.2.1017_darwin_amd64.tar.gz"
      sha256 "27b3888b6624fd4ac1b57adc1914d3a61e8117acf938558ae5828b6c846f57a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1017/agentshield_0.2.1017_darwin_arm64.tar.gz"
      sha256 "9af179181a64e1042e74c059470f4e3f6d0dbc94eb052262f6a4605546f4d71a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1017/agentshield_0.2.1017_linux_amd64.tar.gz"
      sha256 "54b09a0c3754a0f15fb2693f3ba1afd6339127587a195e15a4e89a92ea337fe1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1017/agentshield_0.2.1017_linux_arm64.tar.gz"
      sha256 "54ba7e28cbcf50b86afd154e89f76190902cb2ea3e312ae50baa949ca8e3905d"
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
