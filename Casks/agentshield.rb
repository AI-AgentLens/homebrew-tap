cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1590"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1590/agentshield_0.2.1590_darwin_amd64.tar.gz"
      sha256 "7fbc4e4693f781b99b40fc7ed6c0f29e3858205e3167274cb35420ea6772fb9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1590/agentshield_0.2.1590_darwin_arm64.tar.gz"
      sha256 "316f4df643f2567e113773ab41687b7535279e843872832416157eef0ea18dd4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1590/agentshield_0.2.1590_linux_amd64.tar.gz"
      sha256 "7db8c94f0d243f4ce23fed033e6b740692d70b88b881dcd5c6496282306b4d13"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1590/agentshield_0.2.1590_linux_arm64.tar.gz"
      sha256 "248d4eb31f7635f116f82a60fa3e257c868dd7a1f5c1634253da590136042b7c"
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
