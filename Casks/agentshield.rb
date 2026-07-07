cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1572"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1572/agentshield_0.2.1572_darwin_amd64.tar.gz"
      sha256 "e4c25d8812f407f636af80ef244785b7c7ee2bddd0f00911191649a08d8710db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1572/agentshield_0.2.1572_darwin_arm64.tar.gz"
      sha256 "9e8bac68e3010aab89a2a5448bf81b93b01e4b4d215c528788ccb2b962a48198"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1572/agentshield_0.2.1572_linux_amd64.tar.gz"
      sha256 "a359b106cb67bde4c81d78c95de4bc3eeae4b32915b5de499e5faa0c3ccccf58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1572/agentshield_0.2.1572_linux_arm64.tar.gz"
      sha256 "25609a3a9a46739301114353804d686cef11e53afc3c91a5beada9c33172a006"
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
