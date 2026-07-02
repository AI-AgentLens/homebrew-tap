cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1529"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1529/agentshield_0.2.1529_darwin_amd64.tar.gz"
      sha256 "d609286c55f4759484b9fd28a602d5f7cdb424f0088993bbd5cf8abe61fa8131"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1529/agentshield_0.2.1529_darwin_arm64.tar.gz"
      sha256 "196b5b0a5cd3563d966ddcfcdff73e716874d6a6d0a794adf8c851964b6b143a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1529/agentshield_0.2.1529_linux_amd64.tar.gz"
      sha256 "88a99d860309b9be809d15ce5957269e64eb84327f255fe5a3d564f2c560cf0b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1529/agentshield_0.2.1529_linux_arm64.tar.gz"
      sha256 "c7196db205ad1594a74452d64d59b13642c67bdc38533d08a6973ef72ac73f8e"
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
