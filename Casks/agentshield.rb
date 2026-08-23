cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1934"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1934/agentshield_0.2.1934_darwin_amd64.tar.gz"
      sha256 "6505dbea2ea2373871c2079c6edf245de3b18c8206295d05e227980c60558d55"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1934/agentshield_0.2.1934_darwin_arm64.tar.gz"
      sha256 "370bf608aa67ec6a281e0c0880f6946506fbd16c855c2069a8ed480d021b3700"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1934/agentshield_0.2.1934_linux_amd64.tar.gz"
      sha256 "64637bcbebf9050248c283742e58ece4ea196e5a8cafda58fd9032996175a286"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1934/agentshield_0.2.1934_linux_arm64.tar.gz"
      sha256 "2ac2695eb9603148c82735ca605703388b24fd1237192fa4fade1991c1bfdc83"
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
