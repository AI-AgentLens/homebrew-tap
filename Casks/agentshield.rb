cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.717"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.717/agentshield_0.2.717_darwin_amd64.tar.gz"
      sha256 "0660fff832fd653877a8fdeb1e2148ccbdaf60f6f28a1f4c76e9360fddf6fe69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.717/agentshield_0.2.717_darwin_arm64.tar.gz"
      sha256 "94969710bd106c31767fbebda3b07c62679fac280260e74acf41df930bf970ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.717/agentshield_0.2.717_linux_amd64.tar.gz"
      sha256 "c7b924a3c9eb2eff4d27bee71324d5da86c72041c732d542877e646d0f7ea3bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.717/agentshield_0.2.717_linux_arm64.tar.gz"
      sha256 "142540f0f1a4e797b1d439b152a622c5a750daf7888869551f926de55f5e965b"
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
