cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2056"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2056/agentshield_0.2.2056_darwin_amd64.tar.gz"
      sha256 "5ec4954ef0130318e145698e12b5f841bcdfd39aaf57d5117e913be542ead062"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2056/agentshield_0.2.2056_darwin_arm64.tar.gz"
      sha256 "0ce9eef00b2bf40de774ba1c4e7424455b7814cdb0e27e2deef4bca656791cba"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2056/agentshield_0.2.2056_linux_amd64.tar.gz"
      sha256 "b039e2daec8183d1dfa8a6b7321cd38713efef6c91f3fe705e9a6bbd67a0fac1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2056/agentshield_0.2.2056_linux_arm64.tar.gz"
      sha256 "26d603eb55094fcfc17bdfd3e0f3a2cc9daf532456056b46234deb6fe63a8ef2"
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
