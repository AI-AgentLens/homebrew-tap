cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2472"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2472/agentshield_0.2.2472_darwin_amd64.tar.gz"
      sha256 "15871a66c239a8096f3f6de253ec70fd016cf68be86b8d23fb9b82b44ffed8ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2472/agentshield_0.2.2472_darwin_arm64.tar.gz"
      sha256 "92b58af3fef3b359888dcffbd297ef62fdb063cc17921a62e0b5181d86452461"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2472/agentshield_0.2.2472_linux_amd64.tar.gz"
      sha256 "cb7019646fb442641b2f3f5b65ce2e1c36b7d1d12cf56cd63d6f09adcf01db46"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2472/agentshield_0.2.2472_linux_arm64.tar.gz"
      sha256 "ff1ccfa90930b10df60d1f2975ac6157dd0aa8260b7f19f9c86e402a6247205e"
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
