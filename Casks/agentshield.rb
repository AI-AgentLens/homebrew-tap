cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1959"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1959/agentshield_0.2.1959_darwin_amd64.tar.gz"
      sha256 "64981cf9fa02f1f1963d674860eb62e29666ef14c75368ffcd7c794d23cb77ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1959/agentshield_0.2.1959_darwin_arm64.tar.gz"
      sha256 "f82a8875ea09df627c23698bb6302dbcb014ff9e6b46646b2d50eaf69bc3e49f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1959/agentshield_0.2.1959_linux_amd64.tar.gz"
      sha256 "50cc7f39434e896375a9b9565932f211d25660e1af43071a408a7a87783be286"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1959/agentshield_0.2.1959_linux_arm64.tar.gz"
      sha256 "7113b6f296a913b5ad7f861cd586f3ac88242e6e3bdb7da6a15d605abb9c50c1"
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
