cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.643"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.643/agentshield_0.2.643_darwin_amd64.tar.gz"
      sha256 "13a2d0deb4fea4d6432e8148557c1d268729c7565a9bda65aad5b5665a7d80e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.643/agentshield_0.2.643_darwin_arm64.tar.gz"
      sha256 "0350bf634edfba586b81f363ee6388d300a0936542ea197db74f9ed6637057f0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.643/agentshield_0.2.643_linux_amd64.tar.gz"
      sha256 "9919056c70948136ae9df6fa4fd8fcde044794d88b848c37064f012e8f0adeaa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.643/agentshield_0.2.643_linux_arm64.tar.gz"
      sha256 "dce4c1cb43766739b73b4f4b45da70e83ca390e54a86bdacedb60739965ce23e"
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
