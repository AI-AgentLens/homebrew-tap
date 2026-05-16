cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.998"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.998/agentshield_0.2.998_darwin_amd64.tar.gz"
      sha256 "fffdc867174089c71ae6e5567629561a29588751920a116d084d4b7dc2491de3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.998/agentshield_0.2.998_darwin_arm64.tar.gz"
      sha256 "ee0d300ac2471d7c11014f5535ef7495349c14601b7a45fd11af9595b88feb02"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.998/agentshield_0.2.998_linux_amd64.tar.gz"
      sha256 "f6aeb896761d0e49b17e32f14e8de309c387e786d75d4caf2e4a0e69b589e62e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.998/agentshield_0.2.998_linux_arm64.tar.gz"
      sha256 "855e74b7dac3ae3f01b5fbcd6bad817217906639fb950372bb230170b0b57dff"
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
