cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.906"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.906/agentshield_0.2.906_darwin_amd64.tar.gz"
      sha256 "71e61a4f3d4e52df1b98977b61be14d6db84d7bd9e2c0863291e2c5516158c37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.906/agentshield_0.2.906_darwin_arm64.tar.gz"
      sha256 "4fd67bef744ff6d8bb1f34e9cf2bd860005b76f7b0551e46e97e77a512dcc61a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.906/agentshield_0.2.906_linux_amd64.tar.gz"
      sha256 "9f740dfed60d0054b53fb1f27bba9d9f90b74d37d6cea861e68fec032c369953"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.906/agentshield_0.2.906_linux_arm64.tar.gz"
      sha256 "895a94a6dafa8422d064affe17901aa571ad6fb6b9cce8597094bfc949e15396"
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
