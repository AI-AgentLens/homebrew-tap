cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1445"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1445/agentshield_0.2.1445_darwin_amd64.tar.gz"
      sha256 "bb9e1a065e4c810b2513750c42a80817ba11ad12853460e2ed0f8422c1012a9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1445/agentshield_0.2.1445_darwin_arm64.tar.gz"
      sha256 "5de40ab595d849e4b5715b30b586d130111fabd6ff8dd05e12566887474197b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1445/agentshield_0.2.1445_linux_amd64.tar.gz"
      sha256 "f3d7630489436acabeff5bca5c6451795ae86d69e60afe16a9a01db15afb32a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1445/agentshield_0.2.1445_linux_arm64.tar.gz"
      sha256 "1d183b5be47046527454669513751733e8ce3a59859000353947baf61066552f"
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
