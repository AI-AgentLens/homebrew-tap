cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.930"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.930/agentshield_0.2.930_darwin_amd64.tar.gz"
      sha256 "29651d10304b03195916848a3d5a549739f208b2ccb7be7750aa62168d8ab7bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.930/agentshield_0.2.930_darwin_arm64.tar.gz"
      sha256 "44a796336df9b77b17c36f8bcc7bcb70b92ecb694bafeebef966f521ce67f577"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.930/agentshield_0.2.930_linux_amd64.tar.gz"
      sha256 "59487308dc0cd07e27d657ea28abf4ef978613de11ded0e84f4c490b29fb6dfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.930/agentshield_0.2.930_linux_arm64.tar.gz"
      sha256 "25d2f157284fc7db0fb3f44b90f9c41c3ae3055e59efcb45d1284c6a6059e336"
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
