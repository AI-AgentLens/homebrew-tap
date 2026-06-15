cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1323"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1323/agentshield_0.2.1323_darwin_amd64.tar.gz"
      sha256 "ffa2363fe3887a810b7bdce5a7d12b426b6a971b553e0c5fdd4f0644dfca92d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1323/agentshield_0.2.1323_darwin_arm64.tar.gz"
      sha256 "7e9c58479b9575f3da797531f7cb9e8a43e216bd6dd7a3b24000e67543a3ce1e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1323/agentshield_0.2.1323_linux_amd64.tar.gz"
      sha256 "b1660f01758519a6adc60065d1e38fd24c37ec6597bf95314496f5a6c28aa481"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1323/agentshield_0.2.1323_linux_arm64.tar.gz"
      sha256 "e069082c780830e216f9c19e5e2aeb0be880975b4da1cab23a5343bf2c06a88c"
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
