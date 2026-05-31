cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1173"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1173/agentshield_0.2.1173_darwin_amd64.tar.gz"
      sha256 "ef1edb77662e5140a97895b922704b6a2907473bf0b059547453889cc633ce74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1173/agentshield_0.2.1173_darwin_arm64.tar.gz"
      sha256 "b31ddb0f0ecd2e9d1fe72dc42d9a059ad7a4207e912c31464ecdcb334b6cbdc0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1173/agentshield_0.2.1173_linux_amd64.tar.gz"
      sha256 "27cee56b4cad33b63ae89122d80638fb46d73b4a0510f67aea8bf22f5f061d35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1173/agentshield_0.2.1173_linux_arm64.tar.gz"
      sha256 "9ac21981526a33c94709fe41a1e69c034d84f0c170af90bb4d6cddf326e8214b"
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
