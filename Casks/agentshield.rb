cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.986"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.986/agentshield_0.2.986_darwin_amd64.tar.gz"
      sha256 "e03335f72db45025ff4645fef86f893b8cecaffc1fbf5ba144613dcd7d7870d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.986/agentshield_0.2.986_darwin_arm64.tar.gz"
      sha256 "bb1173e0f88ca27d982ea3d8547effd571c21bad483f8245ee4617a724886fc2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.986/agentshield_0.2.986_linux_amd64.tar.gz"
      sha256 "2c531231a8199ea999e1a373e8704b777473759531122e711a827ed7f752bc4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.986/agentshield_0.2.986_linux_arm64.tar.gz"
      sha256 "c40c867a9c35dd2b0ebf1c014f97f7652ecdb13d0f17e5c35cee40cefef41dd5"
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
