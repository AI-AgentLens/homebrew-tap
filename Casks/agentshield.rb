cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2179"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2179/agentshield_0.2.2179_darwin_amd64.tar.gz"
      sha256 "1f572bcf95754b9fb8c3efee700503820f49b63d784ef8fdad0c306bc1977e33"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2179/agentshield_0.2.2179_darwin_arm64.tar.gz"
      sha256 "ce6b3c75b3e5c477d892ce7c630d2ff3f0095ab3bd39fdb77bee485aaf3308a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2179/agentshield_0.2.2179_linux_amd64.tar.gz"
      sha256 "d15882c4e57d17376518b143f082527aed5aae2fce7389f3d19375f853852c32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2179/agentshield_0.2.2179_linux_arm64.tar.gz"
      sha256 "260f0324882ec523f45fdce37daf1d06961f0b0c2d53c192fff9f8cbd35bf5b0"
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
