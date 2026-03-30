cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.226"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.226/agentshield_0.2.226_darwin_amd64.tar.gz"
      sha256 "12c825619a5bee891b21ba235fd3aca3593726c2dc4b1af59c288dfb9ab96da1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.226/agentshield_0.2.226_darwin_arm64.tar.gz"
      sha256 "d10419921641d0584fb4a8176b239c64380c2f1fd5593034109276d8abd58e55"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.226/agentshield_0.2.226_linux_amd64.tar.gz"
      sha256 "32661df3ef675d4ab1d9fe28b9ff05f59ae71497c830c6e68d66aab9a533e2d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.226/agentshield_0.2.226_linux_arm64.tar.gz"
      sha256 "90a5f94b59909f6c0f9a1977414ae2fc57d52af5a1d5a99c359c7bda968d0f0d"
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
