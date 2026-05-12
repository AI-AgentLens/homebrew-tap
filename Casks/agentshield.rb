cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.959"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.959/agentshield_0.2.959_darwin_amd64.tar.gz"
      sha256 "989de7d880a39aeae3965c32779c9cd3baee127f45e49b742916ffeda0bd8513"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.959/agentshield_0.2.959_darwin_arm64.tar.gz"
      sha256 "99c7f77227bbcc449518121d096fdbc58506dcc007c06244017d9bf314b28348"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.959/agentshield_0.2.959_linux_amd64.tar.gz"
      sha256 "ca43717b933be4153b161ca0a8c3d6352253ffddd5a5b16e6f07a10619c88b2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.959/agentshield_0.2.959_linux_arm64.tar.gz"
      sha256 "809840e6c085004daee81a2abfea010bbc5ab429543757743edd27656467f70d"
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
