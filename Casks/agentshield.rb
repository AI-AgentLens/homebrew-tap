cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1925"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1925/agentshield_0.2.1925_darwin_amd64.tar.gz"
      sha256 "ea7416bbc240909013f10a05af8d65a84aca4a5c733f5461fd97cf43e33c9ddd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1925/agentshield_0.2.1925_darwin_arm64.tar.gz"
      sha256 "8bec078d914d761d558e39b0a845cdadb480953220dce802c40adfba84bdc722"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1925/agentshield_0.2.1925_linux_amd64.tar.gz"
      sha256 "41d2c21598b3fb66d8f7b404ac998088cff1c4388f18209047f53428ce5bddc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1925/agentshield_0.2.1925_linux_arm64.tar.gz"
      sha256 "e4eca8781283505cab6dfd9915d4eb61437f8739afe13cf876005c46942c05e5"
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
