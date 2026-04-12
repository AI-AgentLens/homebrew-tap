cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.559"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.559/agentshield_0.2.559_darwin_amd64.tar.gz"
      sha256 "6b5515bcae6b9c12da103cb6b86c96a42b59cf4310e706678847774e66de3339"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.559/agentshield_0.2.559_darwin_arm64.tar.gz"
      sha256 "9bffe1c643bdb7ddfd2723ecee5c13864885f6077d6bda03a5077f3aee733b19"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.559/agentshield_0.2.559_linux_amd64.tar.gz"
      sha256 "0b6600440ec6c664ff49b1068250be7d1af41bb2cb7bdffb64ceb679f7542c21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.559/agentshield_0.2.559_linux_arm64.tar.gz"
      sha256 "f6f218f0335954c654e97a65307f8173ca9801eb79eed7888a3b1cfd361348bd"
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
