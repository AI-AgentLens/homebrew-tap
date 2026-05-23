cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1091"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1091/agentshield_0.2.1091_darwin_amd64.tar.gz"
      sha256 "a2e074e9a054eb61a004dc5b19518f87653dd3ccb04f513751af3ffbe93d09f0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1091/agentshield_0.2.1091_darwin_arm64.tar.gz"
      sha256 "7d1f00514736ab49908f0081d861691f247afbe4347e27bc48b46869e0bb3ae8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1091/agentshield_0.2.1091_linux_amd64.tar.gz"
      sha256 "36fc6c6b82d43e1ade447e4857bb762bacae76955feb680a488e07a6c99c9747"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1091/agentshield_0.2.1091_linux_arm64.tar.gz"
      sha256 "52157c2e1db8eb47cb9b87241f23bf86795e480675b36140f8c714abf5ff01a4"
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
