cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2245"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2245/agentshield_0.2.2245_darwin_amd64.tar.gz"
      sha256 "d063bf3e1c52268f1247a7a5403fee29fb64587416938cbafea17e3c6070a9c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2245/agentshield_0.2.2245_darwin_arm64.tar.gz"
      sha256 "ce5a1bc9d041440d929f0d5c14184ba61098359f4b4a999cead5635b8811591c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2245/agentshield_0.2.2245_linux_amd64.tar.gz"
      sha256 "95d01890f15bd85a363ffe53d5d23107c8f9395299326bb2cb517339d60d735b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2245/agentshield_0.2.2245_linux_arm64.tar.gz"
      sha256 "ad419aa9b23f6d8f364ee37a9913d547be36a02e7ade8bc89ae4800cd4f57e88"
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
