cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.524"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.524/agentshield_0.2.524_darwin_amd64.tar.gz"
      sha256 "f0cab69182aef69adbf92fcb9942d1156c3f01917f40885ff76e9cb75ae8204a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.524/agentshield_0.2.524_darwin_arm64.tar.gz"
      sha256 "f809509f082a8b9421a02a63e6afa98cf30a8dacd54b6c5046abf7f9a44e8abe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.524/agentshield_0.2.524_linux_amd64.tar.gz"
      sha256 "a740ce0e69c76095d912b317d6d97ef744617461270af7778d35c63678e56d58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.524/agentshield_0.2.524_linux_arm64.tar.gz"
      sha256 "7ea218e505d5a197f2cb3f767ad3f0c9e7dc1e082558e8b7cd8de72920c45f0d"
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
