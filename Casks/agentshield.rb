cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.537"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.537/agentshield_0.2.537_darwin_amd64.tar.gz"
      sha256 "00f28abfabc0e09926dea34a766eb1855e2a893393db2e14ee0c06fbc23c674e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.537/agentshield_0.2.537_darwin_arm64.tar.gz"
      sha256 "f77d49f915515c885c1bdc47005cdca3c47d0550a7c6984f7b05635f72b8f9c4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.537/agentshield_0.2.537_linux_amd64.tar.gz"
      sha256 "6ad2520849bc37e12aae0b2c51c55e7ada2ff8efe356987668f23b2b96827dc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.537/agentshield_0.2.537_linux_arm64.tar.gz"
      sha256 "00f73becf926dbd42005f8432bcd3f08e3634061cf8a3ea40eb2d351f916c03b"
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
