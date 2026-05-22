cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1074"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1074/agentshield_0.2.1074_darwin_amd64.tar.gz"
      sha256 "d48482da5ffa6d654c7dd3d1d1ac67df0a0bdce0489e7abf79a3ff59c61aa9e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1074/agentshield_0.2.1074_darwin_arm64.tar.gz"
      sha256 "428d73bb6194f8c8fa1da2038dc93562fd02e8810a828335bcb15c6d424efa2a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1074/agentshield_0.2.1074_linux_amd64.tar.gz"
      sha256 "5bdf5079e665b3c758126aa83e10649123a5f124226ba87afc2201eda00e2895"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1074/agentshield_0.2.1074_linux_arm64.tar.gz"
      sha256 "d57a1cfba4c1477ecf11e8f82b6589ace6435b8e43e41746249ec283e02be522"
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
