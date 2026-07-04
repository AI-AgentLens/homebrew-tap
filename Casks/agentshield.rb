cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1548"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1548/agentshield_0.2.1548_darwin_amd64.tar.gz"
      sha256 "68bdf850f222d520b86952d76e8a8d1e3047d36fd42c98539a416acccd9654cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1548/agentshield_0.2.1548_darwin_arm64.tar.gz"
      sha256 "f1569f97a00252293554a7e8eca0b9c5ddbc32693e9617c927f94d12978c2c63"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1548/agentshield_0.2.1548_linux_amd64.tar.gz"
      sha256 "30048ac0db384f369d92f5c3826d54db72e7dde0c361ca2958617d9e1168a7db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1548/agentshield_0.2.1548_linux_arm64.tar.gz"
      sha256 "7f918e73b8989876c7241a150223019c881432d59d04afc77920f3dc9a536f93"
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
