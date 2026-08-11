cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1818"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1818/agentshield_0.2.1818_darwin_amd64.tar.gz"
      sha256 "6423c188b77a50e215cfc2a26eede7d21bd358a734ffd3c01d3be0ce8992d7ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1818/agentshield_0.2.1818_darwin_arm64.tar.gz"
      sha256 "bed38a3fb488ab97533afb0f42f4d7997e7a08bb9094e041fd7416876def6626"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1818/agentshield_0.2.1818_linux_amd64.tar.gz"
      sha256 "31a9bf53d4d73d2cb3da489dc7e445a33cd89b4ff1f9a5c82db1b3a18085d085"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1818/agentshield_0.2.1818_linux_arm64.tar.gz"
      sha256 "0209e62199d55d798a6773cdff2f914df135c9c683202ff99dede7a74c2557c6"
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
