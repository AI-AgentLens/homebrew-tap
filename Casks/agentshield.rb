cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1143"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1143/agentshield_0.2.1143_darwin_amd64.tar.gz"
      sha256 "1ed03f945efd7f9a38bdfe1e32032b256879ad8429d06a95bb1b4cbcbe52e9ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1143/agentshield_0.2.1143_darwin_arm64.tar.gz"
      sha256 "f69e514046404318e7eda8164d975fe824be50fe6f0ff5476efa622bf858f1bb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1143/agentshield_0.2.1143_linux_amd64.tar.gz"
      sha256 "403477076912e7a065218ba68a59b7e348eb0b64c97dc012c7dd48da1023245f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1143/agentshield_0.2.1143_linux_arm64.tar.gz"
      sha256 "8148b394fc0f350ae6ba9f50c035248897ee11b5e6c966565f79c9135fd648bd"
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
