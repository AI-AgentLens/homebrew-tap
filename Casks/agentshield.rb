cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.634"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.634/agentshield_0.2.634_darwin_amd64.tar.gz"
      sha256 "e961a809b4b0d9a7a583c397655635bdeb37801de8f27e762da3ee4301f734b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.634/agentshield_0.2.634_darwin_arm64.tar.gz"
      sha256 "5bcbeefb1dd4a26a7f8a71f289720db74f8fda1c9000de6f6dd97ba2dfd56c19"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.634/agentshield_0.2.634_linux_amd64.tar.gz"
      sha256 "e3e56a8e6728f44dab6ee87fa20057c9751656955df701926980102fddcfdcc4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.634/agentshield_0.2.634_linux_arm64.tar.gz"
      sha256 "99e0666d2131f3031333d5ebb6d9bf75baea44ea920b012ba6acb450f1e39314"
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
