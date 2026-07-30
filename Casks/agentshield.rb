cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1761"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1761/agentshield_0.2.1761_darwin_amd64.tar.gz"
      sha256 "f985520f3c0c216de6eb3e3dece45c1dac594b411c100baadc18784a29c292c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1761/agentshield_0.2.1761_darwin_arm64.tar.gz"
      sha256 "908c360d9f868cffaa139745a86a603afb51a17414593ac5727d32e6674ab6a1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1761/agentshield_0.2.1761_linux_amd64.tar.gz"
      sha256 "cadc38cea7c5010a635afea272dd1320e3a9a4d390effe21828d4300f027a2a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1761/agentshield_0.2.1761_linux_arm64.tar.gz"
      sha256 "47d32846803ea3ab47753afa2df7e78c94fe0e27f083c85fdb53718b91b20004"
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
