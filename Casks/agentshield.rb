cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2148"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2148/agentshield_0.2.2148_darwin_amd64.tar.gz"
      sha256 "e746860f6e706d724b20c8455bf1c6ea6ceac1d6b7685e1817c85e2efb6440d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2148/agentshield_0.2.2148_darwin_arm64.tar.gz"
      sha256 "a65989372a9c0372940941ed2033b20c792f87c76ad6c3d069e4e21d6c3613da"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2148/agentshield_0.2.2148_linux_amd64.tar.gz"
      sha256 "6936c46bfa6b490a81c3d5cd887273c65e427977af5988090ba56e12d58ffb9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2148/agentshield_0.2.2148_linux_arm64.tar.gz"
      sha256 "d58e4fb4bce61e0212b5610a0c8b93a1100fc228ed43f6202ab5f098673f33bd"
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
