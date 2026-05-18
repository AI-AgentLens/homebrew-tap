cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1020"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1020/agentshield_0.2.1020_darwin_amd64.tar.gz"
      sha256 "5a1a85eadf71b7bfa71499e059c7c444252a4fbbd3ad547915d548cd534a726f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1020/agentshield_0.2.1020_darwin_arm64.tar.gz"
      sha256 "7e9ab237742551dc2340ac9509594b1fbc187f334abb936470eff5b86e219584"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1020/agentshield_0.2.1020_linux_amd64.tar.gz"
      sha256 "995239f91b3b28f3be3cf8c332d24e55cc124c0e3bb078b8c65986004dca28c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1020/agentshield_0.2.1020_linux_arm64.tar.gz"
      sha256 "2b02ceccb277f5f59ad4073264e10e8d457593c177ab448d16758fcbcd9c3f5a"
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
