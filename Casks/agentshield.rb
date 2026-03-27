cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.91"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.91/agentshield_0.2.91_darwin_amd64.tar.gz"
      sha256 "ff9a2bd4879878166353fbcbd57535d3953ffac0c18344c71439a7b7e0728dc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.91/agentshield_0.2.91_darwin_arm64.tar.gz"
      sha256 "1a6c820f84aa6de8e084aedfee85eda2e7b47c8820d2767a0ca9a43d355924fe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.91/agentshield_0.2.91_linux_amd64.tar.gz"
      sha256 "a423a4c432df0ac13309d3b7f25b4f15691daf1a8c122b33cf831990dd74c640"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.91/agentshield_0.2.91_linux_arm64.tar.gz"
      sha256 "e41d41777d5b025f0ce998872eeab5d0f53f10fac9d5c1ebb4afd296ab35ca92"
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
