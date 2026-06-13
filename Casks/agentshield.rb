cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1307"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1307/agentshield_0.2.1307_darwin_amd64.tar.gz"
      sha256 "bb777321341729b774af9c7c9cd8f3069a13918b8d70af3f77c483eb58473db6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1307/agentshield_0.2.1307_darwin_arm64.tar.gz"
      sha256 "0dad827ea26d766c644eb622cb7cdfd2a0f97797d5115bd879cb89eee10c45c3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1307/agentshield_0.2.1307_linux_amd64.tar.gz"
      sha256 "26a86b04b866457cd95c642c42b08a9a411fd6798f776ac284749a1da1f8699d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1307/agentshield_0.2.1307_linux_arm64.tar.gz"
      sha256 "1fa799aa9ce5e11f3cbf0fa341cbe59ad034e5b3426e835f281cfec73aca6630"
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
