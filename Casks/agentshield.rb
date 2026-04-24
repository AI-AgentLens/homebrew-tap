cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.706"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.706/agentshield_0.2.706_darwin_amd64.tar.gz"
      sha256 "112b93e2700c7d1751e5415af04ad0e4b2e96b386df09ecf848f3ff91d9df082"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.706/agentshield_0.2.706_darwin_arm64.tar.gz"
      sha256 "5b076a2852f71b1e088e31a6970f3b8949d1ebce0bc7f31358d0317cf5364ff4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.706/agentshield_0.2.706_linux_amd64.tar.gz"
      sha256 "8b583d2960edaf349a4dfbe1ed5335d22486896d81992fa3402452e94c421f48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.706/agentshield_0.2.706_linux_arm64.tar.gz"
      sha256 "8c2810a7e21cb4278345f4aba73ec11586a73f7bf0e3bea90d093041d4e6cae6"
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
