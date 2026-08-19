cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1903"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1903/agentshield_0.2.1903_darwin_amd64.tar.gz"
      sha256 "1a93cb4be2f99f1b8e025a10f20043fe644808de5c68b3adb3a04977e35688f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1903/agentshield_0.2.1903_darwin_arm64.tar.gz"
      sha256 "29b41615f27f7b7e98c4cf1aefeb49f003099772581336c5011069e26b3a9ccc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1903/agentshield_0.2.1903_linux_amd64.tar.gz"
      sha256 "6a02ecbd3dfe754256ee188047636d2f71ab66e3c961e9dce8325b9f9d416af8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1903/agentshield_0.2.1903_linux_arm64.tar.gz"
      sha256 "26b857c74c6986e5a0d00eab807c5fb8708c706e329eb786665d3b3617d02259"
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
