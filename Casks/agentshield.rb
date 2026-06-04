cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1205"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1205/agentshield_0.2.1205_darwin_amd64.tar.gz"
      sha256 "c018ec91526cce9306d8f3994fb57b94d323382cf450ba428bb904caf33dce02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1205/agentshield_0.2.1205_darwin_arm64.tar.gz"
      sha256 "eec27cd6062a0ab12bff5bd4b30b954a7db65448b5317bc6acea4b8999df10b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1205/agentshield_0.2.1205_linux_amd64.tar.gz"
      sha256 "663d496fc9b3e158ebc0cd65054edbd2f9452aa51c352dd339d319ed502dd74d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1205/agentshield_0.2.1205_linux_arm64.tar.gz"
      sha256 "8e5cadbb357341036e61316132c1a86f4996c93409beb37a9026b8fa91048e3a"
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
