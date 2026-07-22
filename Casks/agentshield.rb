cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1710"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1710/agentshield_0.2.1710_darwin_amd64.tar.gz"
      sha256 "0144c9ba39df3fbc4e25026c9f60ca4c042c8c49655f2661bc789f7aaf42405e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1710/agentshield_0.2.1710_darwin_arm64.tar.gz"
      sha256 "23e78a3c380572bd1cedacf5aed4e8d47229fe3adde9eb53bae89e952157c723"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1710/agentshield_0.2.1710_linux_amd64.tar.gz"
      sha256 "b5c7915a957ac2bbbfebead5bbb0c65653411bdaa218cf4e32bfaf75e81bd979"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1710/agentshield_0.2.1710_linux_arm64.tar.gz"
      sha256 "319e85cf061237688e765be4d8d4f1d1c5868c0e54493227f1bb84fe0de6fec8"
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
