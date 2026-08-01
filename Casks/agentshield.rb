cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1770"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1770/agentshield_0.2.1770_darwin_amd64.tar.gz"
      sha256 "b917cddde21ca48271e362e75778825a6a3e1bab4e9a9700a7525ac917d91e6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1770/agentshield_0.2.1770_darwin_arm64.tar.gz"
      sha256 "fbaa20432853c5cd1f9637b5045dc17988493007ad474f92863d650364ae30b8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1770/agentshield_0.2.1770_linux_amd64.tar.gz"
      sha256 "37e062e4eb2e8c8210c16fe0f89d491151ba7d483b4c8c1cb6acba8a6f8e83b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1770/agentshield_0.2.1770_linux_arm64.tar.gz"
      sha256 "c4e2de6921fd84b2de8300216a5081e969016cf5f248eb7ddb50dbde10894bbf"
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
