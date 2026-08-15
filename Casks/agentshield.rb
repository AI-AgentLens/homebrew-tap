cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1862"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1862/agentshield_0.2.1862_darwin_amd64.tar.gz"
      sha256 "4312c802c58548236d38b1e9ff33df72af1c956459718113a4a676fc9dc9c033"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1862/agentshield_0.2.1862_darwin_arm64.tar.gz"
      sha256 "32ea9b18cb8216327a7b98d03c3ee9ffe5432a6d6586823c92a7bbc4eee7de90"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1862/agentshield_0.2.1862_linux_amd64.tar.gz"
      sha256 "7fb9783e466e33e575a70152205e9a1add78ed2fff494d8b4364784c90da1632"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1862/agentshield_0.2.1862_linux_arm64.tar.gz"
      sha256 "765da4cf89bea786b8da8802bf9f34821da9a495353d40d8b09a9f7c1d05f957"
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
