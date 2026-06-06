cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1229"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1229/agentshield_0.2.1229_darwin_amd64.tar.gz"
      sha256 "a862c534ea5c77c2f49e6c0fca191552dba84a5a81275dba1029e2c25e442f65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1229/agentshield_0.2.1229_darwin_arm64.tar.gz"
      sha256 "1d4286b73acd5b8349103bcfa6698c2f69672373cff4dfa9fd0c2ef70bc4dd0e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1229/agentshield_0.2.1229_linux_amd64.tar.gz"
      sha256 "3ca2193d5e4248b9439806c84b8ddcd8555e7fe8ea182544160fc0c9e2da7635"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1229/agentshield_0.2.1229_linux_arm64.tar.gz"
      sha256 "4c4ddb1d25728547b0b123dec0d5a7ddc3cb1bac7e56e7a4884ed20a1305161d"
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
