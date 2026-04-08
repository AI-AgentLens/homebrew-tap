cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.486"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.486/agentshield_0.2.486_darwin_amd64.tar.gz"
      sha256 "3af0479b6831e05ea56084b32c7604dd48b75159c77c3f4c7204a036deb2cb43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.486/agentshield_0.2.486_darwin_arm64.tar.gz"
      sha256 "9543bfc6f149c8152c9d173c145a371c0c95bd000c13c5d768d203929afee871"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.486/agentshield_0.2.486_linux_amd64.tar.gz"
      sha256 "9ee10b1fd846fdbf5c6a4ac031fe352cbe64aaae068346fca3819d0986d60d16"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.486/agentshield_0.2.486_linux_arm64.tar.gz"
      sha256 "db61253bfc07956f34db265037451bfa60556d1ef0d58da9fb1defcc0c4a3116"
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
