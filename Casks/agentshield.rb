cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2314"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2314/agentshield_0.2.2314_darwin_amd64.tar.gz"
      sha256 "08052227a8476ac087cb1800c863841e6709b0ec08406584b5c7ed197dccf1f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2314/agentshield_0.2.2314_darwin_arm64.tar.gz"
      sha256 "5b9c09a9b763efdac7d7c198d80aff1fbcb0dfbf35acae422aabdf2f0e13f658"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2314/agentshield_0.2.2314_linux_amd64.tar.gz"
      sha256 "708e123184933e9c457bb024fb4c7a215c7c7536eb79550a7ab1f4ff3fa0aadc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2314/agentshield_0.2.2314_linux_arm64.tar.gz"
      sha256 "e245154c4476f09a5ae167acd0fc21b81e1f3f884026c29e89bcc0e9eb77d43a"
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
