cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2205"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2205/agentshield_0.2.2205_darwin_amd64.tar.gz"
      sha256 "14122109ff79825115ba49e67262f6775fc388ea1811565d72e3125f29a84e58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2205/agentshield_0.2.2205_darwin_arm64.tar.gz"
      sha256 "0136b67d41c61c6aa15f1741bccbd7b2b74352cef31585e4d54c0cbe560c7390"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2205/agentshield_0.2.2205_linux_amd64.tar.gz"
      sha256 "b679a89169c4480de5aaadd55ec6c800dfeb5e4be3c42ea9b47d52438bf85f33"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2205/agentshield_0.2.2205_linux_arm64.tar.gz"
      sha256 "8325a5739da22569ed79f698917c226ee6d029a0e5055a838c75ae2bf22baa49"
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
