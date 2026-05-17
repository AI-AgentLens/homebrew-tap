cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1013"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1013/agentshield_0.2.1013_darwin_amd64.tar.gz"
      sha256 "a5520986da99f70d2c18d422788c099f63c18e3e4c27169b35c13735ffa3212d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1013/agentshield_0.2.1013_darwin_arm64.tar.gz"
      sha256 "b4abe772cdbd33797a3152e46b56d287098bb77688bbbeeca341f7e4d24dfd89"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1013/agentshield_0.2.1013_linux_amd64.tar.gz"
      sha256 "3e2dc0424869d8de14a16b2f3092eb4a268524d55d2ba4c5549188ac48c4a4b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1013/agentshield_0.2.1013_linux_arm64.tar.gz"
      sha256 "5429f5b97153254584de3c5c32b74d706385925b24b600e9cbc84a3eb313e27a"
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
