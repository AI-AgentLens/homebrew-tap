cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1510"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1510/agentshield_0.2.1510_darwin_amd64.tar.gz"
      sha256 "f827f401b618807b443f4ed0abb876753dba9246a8989c88e196788a20d5bfb4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1510/agentshield_0.2.1510_darwin_arm64.tar.gz"
      sha256 "7d076431dbbd1c5171ad6af619e55107f6968825f4652b9e0c701d61f9b93a4e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1510/agentshield_0.2.1510_linux_amd64.tar.gz"
      sha256 "1ac1b5c327d715d63e7e970f6e227fca0d99e9b2e58ba349dc16957df681b197"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1510/agentshield_0.2.1510_linux_arm64.tar.gz"
      sha256 "187b61c31688efbfecc90ea2cd295e94900e31469a72222cfc20deac540f6e64"
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
