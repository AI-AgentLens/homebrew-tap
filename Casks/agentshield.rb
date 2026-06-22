cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1402"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1402/agentshield_0.2.1402_darwin_amd64.tar.gz"
      sha256 "d0762b311ee43bdadeeac74c3af08c75c4ae8c48736544736a05f39a2f1fe029"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1402/agentshield_0.2.1402_darwin_arm64.tar.gz"
      sha256 "46e3c1e2387d8a24e43bc3091ceb3c7f3eedfd3e55882e45b091e67ee9003750"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1402/agentshield_0.2.1402_linux_amd64.tar.gz"
      sha256 "22c46d9cdc29928c73c648bd3f0b8c578e1c195879e96e0de7a8e0b3de37af6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1402/agentshield_0.2.1402_linux_arm64.tar.gz"
      sha256 "b9663777e1489483b7fa73da1c1f8e927ac90a5d650669c34eef808dd3651330"
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
