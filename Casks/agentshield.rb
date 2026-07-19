cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1678"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1678/agentshield_0.2.1678_darwin_amd64.tar.gz"
      sha256 "89323352f6a11718f37a4b7daa358d475cee696e41823fa1858c80ba6e873ba5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1678/agentshield_0.2.1678_darwin_arm64.tar.gz"
      sha256 "766e636caa794adfe2a1c4e8838daebd3fc76ae638505e8d8a3de1764aeb784c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1678/agentshield_0.2.1678_linux_amd64.tar.gz"
      sha256 "1b896352fd841292d75790e0d062598e4b8d23fc4e389dfc9c98f6f48e4631d0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1678/agentshield_0.2.1678_linux_arm64.tar.gz"
      sha256 "2dbda14d63170ee1018cb1e51cec7b1bcd2c4bbbe3abab922dae28692e128dc5"
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
