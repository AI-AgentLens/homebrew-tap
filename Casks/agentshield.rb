cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2084"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2084/agentshield_0.2.2084_darwin_amd64.tar.gz"
      sha256 "a69eece14d23dacbb3988e0ac580575639a9e87624df56c1ae7a85614baa8fa4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2084/agentshield_0.2.2084_darwin_arm64.tar.gz"
      sha256 "4f046a267d68d0681a08f7dab045824ae7f267aa9759c27f31ffd91e21b0e459"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2084/agentshield_0.2.2084_linux_amd64.tar.gz"
      sha256 "c489063d31a7f8fb19d147d000d9b160af21013e41a1a99a560a68a31fd2fb49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2084/agentshield_0.2.2084_linux_arm64.tar.gz"
      sha256 "a4a755bcaedac44b0699f826ab42a21a96ecf5cc88e65eac63404ed859988d88"
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
