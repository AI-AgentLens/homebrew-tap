cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1593"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1593/agentshield_0.2.1593_darwin_amd64.tar.gz"
      sha256 "973f2bba4b90e0ccc1baafe11c4d57900c1b5c8b809f3c175a125aaa275b2328"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1593/agentshield_0.2.1593_darwin_arm64.tar.gz"
      sha256 "6171d7cb9edf72f106c0d56e91288a49f20968e2935e93ff65903ab8c67b3e4a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1593/agentshield_0.2.1593_linux_amd64.tar.gz"
      sha256 "f1596ac0d4b2db137f8b086e3b91186c4adfcf0072b72045382767fdad83eb42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1593/agentshield_0.2.1593_linux_arm64.tar.gz"
      sha256 "e3886b18c5500af6247cbb8fd20d7504826334cc5c097cb1b89067786aa9573b"
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
