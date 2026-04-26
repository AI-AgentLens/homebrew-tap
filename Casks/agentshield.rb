cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.744"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.744/agentshield_0.2.744_darwin_amd64.tar.gz"
      sha256 "bceebe46d71b58666f3d52afeae6d1655b673c950085ec479b7eb315cff0afc7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.744/agentshield_0.2.744_darwin_arm64.tar.gz"
      sha256 "2a5acdf8e8d8f8746b42096594643d999c7df17e27b9e3cf8afb4563a3dc2b50"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.744/agentshield_0.2.744_linux_amd64.tar.gz"
      sha256 "5d314b6a98651fddcfa1c04461fd3b6a160acfbba6e8d7fca5d2766f922d5a42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.744/agentshield_0.2.744_linux_arm64.tar.gz"
      sha256 "0039f987593c6973d0eab3b98237e421af456ef59f199d67a1acd198d6bab3b2"
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
