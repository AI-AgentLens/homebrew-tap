cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.362"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.362/agentshield_0.2.362_darwin_amd64.tar.gz"
      sha256 "33dc5d2d18464a59d40afa48c6b68e52326e03a8c6a521cae5cb03d14660ccbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.362/agentshield_0.2.362_darwin_arm64.tar.gz"
      sha256 "0862f456123b3c3e902b70a3bf1328e2b8cca0d0e6cf7746a4fe81cff3ca0732"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.362/agentshield_0.2.362_linux_amd64.tar.gz"
      sha256 "884629627f03285e6081a70e8a864732f2081932cfc30fb3e73a0217e7e71a1a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.362/agentshield_0.2.362_linux_arm64.tar.gz"
      sha256 "f1945e80ac67dedb56cb5c453dad3135daaa13a86f8bd135bfcd12fd2bf6aa06"
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
