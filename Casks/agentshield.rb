cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.584"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.584/agentshield_0.2.584_darwin_amd64.tar.gz"
      sha256 "b4b0a4ef95842f69f75cc2d6e965b403c927fa5840840dee986d14cee51719c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.584/agentshield_0.2.584_darwin_arm64.tar.gz"
      sha256 "1f67e087fa69a4d8f51c9eb06be81998d983329333c4b29a528c8d3c9291cdc8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.584/agentshield_0.2.584_linux_amd64.tar.gz"
      sha256 "81d6f7e647c438d4e6edf0eca13df8f7042ed20060370e6e770c4b8e45fa4553"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.584/agentshield_0.2.584_linux_arm64.tar.gz"
      sha256 "54f57026a2de64f119c04177d2cfcd9767c5229c53d9464f78a433a826f895fd"
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
