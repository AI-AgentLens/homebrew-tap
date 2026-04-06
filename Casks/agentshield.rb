cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.424"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.424/agentshield_0.2.424_darwin_amd64.tar.gz"
      sha256 "991a70683ebbbfbe302e425d4b555bfb88c1745fb116f848e77d18f572581cd2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.424/agentshield_0.2.424_darwin_arm64.tar.gz"
      sha256 "898b91eddbbc73b685c81d9304b0b01587375c6a6f65ec6d5183eed568da3f6e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.424/agentshield_0.2.424_linux_amd64.tar.gz"
      sha256 "b316c1defcad2377c17d9404a6ed1cb163ddcb0dd7bc4d3fe02d84a1af976e4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.424/agentshield_0.2.424_linux_arm64.tar.gz"
      sha256 "b4f9e9ac4c29ffeaa52942329b5c8f3c75b71028e257f71844023fff8f06d376"
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
