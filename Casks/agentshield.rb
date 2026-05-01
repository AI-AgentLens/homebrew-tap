cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.844"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.844/agentshield_0.2.844_darwin_amd64.tar.gz"
      sha256 "a0f81516148f45badcf127f8214c1ed5d7b237feee53ef5d215c137b00cd1d3f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.844/agentshield_0.2.844_darwin_arm64.tar.gz"
      sha256 "140f6df07b0d4494ef09274baab73bf33137f0948c6fcb33b577b8e187a13929"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.844/agentshield_0.2.844_linux_amd64.tar.gz"
      sha256 "ef0901a97e0c0749cd98d2d214ccf745893efbbd0aac6ef232df187b4679367f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.844/agentshield_0.2.844_linux_arm64.tar.gz"
      sha256 "1a1d30c826097e81461624fe86de3bbf87b3b151c11176f840be9e5edc2b73d3"
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
