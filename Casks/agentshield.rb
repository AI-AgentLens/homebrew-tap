cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2172"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2172/agentshield_0.2.2172_darwin_amd64.tar.gz"
      sha256 "8ef29acab3214598d252400b8f27bc81840e23a505cd118dcd96176c7893ea5a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2172/agentshield_0.2.2172_darwin_arm64.tar.gz"
      sha256 "afa155dcf2ee20f5fb060e5fbd94dbba97e5ed34865b5a540f11d9266c4dee80"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2172/agentshield_0.2.2172_linux_amd64.tar.gz"
      sha256 "d76352042470b53e661343175d49116136fdcc3e7abdca9baa58b8a686d84245"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2172/agentshield_0.2.2172_linux_arm64.tar.gz"
      sha256 "9d785d2d4236fdc93e74f297bbd2327de18116189c22b17ca5a352c1e286dda6"
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
