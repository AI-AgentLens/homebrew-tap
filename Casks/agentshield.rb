cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.535"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.535/agentshield_0.2.535_darwin_amd64.tar.gz"
      sha256 "b35a4bb18acaba233ab260f68821365c883fa898bf3d236a1084698d7fa079f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.535/agentshield_0.2.535_darwin_arm64.tar.gz"
      sha256 "31f421273662a7babbd99ddcb6d8945fb98aeb28849ba4ef25a587a469355335"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.535/agentshield_0.2.535_linux_amd64.tar.gz"
      sha256 "374df6b118aa97426c661b4edf1dfdadab37a1d6b251c4f3aea5741ef8d6a6ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.535/agentshield_0.2.535_linux_arm64.tar.gz"
      sha256 "c5b4bee0ba07aa47717ad467d4ebd2674edc01898b729ad750cf0d965581c4a9"
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
