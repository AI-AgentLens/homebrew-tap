cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.606"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_darwin_amd64.tar.gz"
      sha256 "29c863eab58b9c39c2ab3b7c4df3dc76d7078cab5991f1ea049ac49c9533e654"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_darwin_arm64.tar.gz"
      sha256 "3163d46f3fb6c4a0da8292bcf956439ed8167abe39ece9ea97b0e18474bba535"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_linux_amd64.tar.gz"
      sha256 "a7337e1d4ac6d5209eedf5a11342ec2795e01b5c284f49effadaf52212695879"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_linux_arm64.tar.gz"
      sha256 "8e3b7637c53b845ade471251ffc6b670db3a80f262c0e30034b163ca7af9d7fe"
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
