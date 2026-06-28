cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1473"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1473/agentshield_0.2.1473_darwin_amd64.tar.gz"
      sha256 "7be39d2dd6438517a7f47a4f9d694f6e9041b60093fead5b0ac0276f9a2d579e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1473/agentshield_0.2.1473_darwin_arm64.tar.gz"
      sha256 "f34dbb7e5f3af637c42417c91d0699134e9234298c7da2a466f8b2c0b8b15caa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1473/agentshield_0.2.1473_linux_amd64.tar.gz"
      sha256 "a2b3ad14b8adabebb951f9e5a24a68ad0713de5ce7b2abdf59f922df8145ae47"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1473/agentshield_0.2.1473_linux_arm64.tar.gz"
      sha256 "979bb473890fcf3025d25781f57e0729a5c757350b77b530a189190d5abcd31c"
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
