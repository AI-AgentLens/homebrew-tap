cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2022"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2022/agentshield_0.2.2022_darwin_amd64.tar.gz"
      sha256 "b610c5363f31c8698f00214b1fc00c15fd4ba697e365ae7c5d4f425f76ff00f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2022/agentshield_0.2.2022_darwin_arm64.tar.gz"
      sha256 "6c795d7f044023c9c3814850366a33b8d2cbabd249ceb33dff758a811aefc1e6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2022/agentshield_0.2.2022_linux_amd64.tar.gz"
      sha256 "ce40274c3cfe5fb492f5be119f6c2dad95463b4041ab6e54b02fdecd16aaf6fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2022/agentshield_0.2.2022_linux_arm64.tar.gz"
      sha256 "a109a29b26a994bdb468612d225620763c6af8f781fd6bd7729a5bb23a566019"
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
