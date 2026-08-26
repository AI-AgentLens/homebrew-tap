cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1958"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1958/agentshield_0.2.1958_darwin_amd64.tar.gz"
      sha256 "81e22904725083a1a86d984ab94ba2ed739f0af9de5afac55e2a155d8f71ce71"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1958/agentshield_0.2.1958_darwin_arm64.tar.gz"
      sha256 "4ae917234d9f83644bd5896d5762687c7c73654184196f917a12347bea83b3f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1958/agentshield_0.2.1958_linux_amd64.tar.gz"
      sha256 "c01a42c7963e2c31b0aab94268e25c153a6125f286e14b692e9f1419f9a88840"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1958/agentshield_0.2.1958_linux_arm64.tar.gz"
      sha256 "08b44a2eab46ee0db4dc85f652a35b1116df8ef5b46ec722dab3b279bdddb9bb"
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
