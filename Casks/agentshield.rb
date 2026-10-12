cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2416"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2416/agentshield_0.2.2416_darwin_amd64.tar.gz"
      sha256 "0153d71725078ebc5dc68541cd1ed04451f1893cf5853cf7ab19fe038b48414a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2416/agentshield_0.2.2416_darwin_arm64.tar.gz"
      sha256 "d4afd0219067a0f0e2089c85c21067584fa72891f70725dcd9742b4fd3eda6a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2416/agentshield_0.2.2416_linux_amd64.tar.gz"
      sha256 "7bf8f476d0900c19f4e1f0308bf9514406d426290533b14e5148dc1510a70b6d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2416/agentshield_0.2.2416_linux_arm64.tar.gz"
      sha256 "5fded49424e3bd66335463a2c5b9273d8eb1d2d5847b85f3f4ed991301ffb24d"
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
