cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1856"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1856/agentshield_0.2.1856_darwin_amd64.tar.gz"
      sha256 "b1be374450f60bae56f0c22086d805ce11f3d06eb1dccf4826d5676b8dc97d2c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1856/agentshield_0.2.1856_darwin_arm64.tar.gz"
      sha256 "35b9a6f734f0723a445fac05fe6b113236744275604401d3210e7007b61d4b4e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1856/agentshield_0.2.1856_linux_amd64.tar.gz"
      sha256 "d3a4b3bc8dc11032e5942e143e99f1593fc9ff9ae33fc01c198846371b990d70"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1856/agentshield_0.2.1856_linux_arm64.tar.gz"
      sha256 "d415517eb8918eb12fff39323618d8158086391e010ff70add137b9f58cc4de7"
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
