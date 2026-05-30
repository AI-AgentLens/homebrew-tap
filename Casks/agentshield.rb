cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1156"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1156/agentshield_0.2.1156_darwin_amd64.tar.gz"
      sha256 "21571745f9c3f7356d9ae011df5c5a9cc11da0d0b6c7d62c5befc8b9a15499a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1156/agentshield_0.2.1156_darwin_arm64.tar.gz"
      sha256 "8379f7014aec79e32f3605db628d58d7a02aa6586603553e0c0a50f240bcaf91"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1156/agentshield_0.2.1156_linux_amd64.tar.gz"
      sha256 "7be9db2e1dc4c32217daae20fae3ebe3f39e78fc411c4f66fa88585f20a07265"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1156/agentshield_0.2.1156_linux_arm64.tar.gz"
      sha256 "c2057daad462fc41d979859b765c12cc2d3ba8d776c2bc1ba193145a2320183e"
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
