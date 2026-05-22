cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1079"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1079/agentshield_0.2.1079_darwin_amd64.tar.gz"
      sha256 "dfc90e711e80af19dc0761807e3a1dd3e4ce010cd912b9e1f4fc99d6fd0f61ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1079/agentshield_0.2.1079_darwin_arm64.tar.gz"
      sha256 "08ef108b8fe3dde1d7ad9697e39b6c9629130057eed3e15de4b3c136a34bf754"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1079/agentshield_0.2.1079_linux_amd64.tar.gz"
      sha256 "53bda2fd5d4f5272a24caa8639d2247d3f2b5754b34b0eabe2360804b50adc1d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1079/agentshield_0.2.1079_linux_arm64.tar.gz"
      sha256 "e9eded01cfe202fdb6438c4fd18da58481eb133b7753da151a7552d09c03e9e3"
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
