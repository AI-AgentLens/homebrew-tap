cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.233"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.233/agentshield_0.2.233_darwin_amd64.tar.gz"
      sha256 "c93a8ffc62851a459669bba3bde83f41da535d2b65f38e820f481c4f0bf82a36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.233/agentshield_0.2.233_darwin_arm64.tar.gz"
      sha256 "a59456e7eec9f54c6165ef811a0b69244141907a3f5881205b63d6a967f1d187"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.233/agentshield_0.2.233_linux_amd64.tar.gz"
      sha256 "c1256e5127fe6c6c76303a86cda0df1a3d9465e824a9fe056c84de45c47b2170"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.233/agentshield_0.2.233_linux_arm64.tar.gz"
      sha256 "ce7431a4cdde925898ec50dc2a83bf3e00c5f7c61bc8c2baeb6b60ebec8ed635"
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
