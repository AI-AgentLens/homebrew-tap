cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1054"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1054/agentshield_0.2.1054_darwin_amd64.tar.gz"
      sha256 "a6cff8065ff51b92b02aedb2a4bd052c91c36b66a54a1707848f6535d5c3930d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1054/agentshield_0.2.1054_darwin_arm64.tar.gz"
      sha256 "6e44253e3e14ca0e31fc833e1ef19e55a83646c86052d03756b6be9ccd95ffd5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1054/agentshield_0.2.1054_linux_amd64.tar.gz"
      sha256 "8c729225b93c212d2fd17f3016f8cd9ff62278b2fd8b1307c188607ceea99a09"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1054/agentshield_0.2.1054_linux_arm64.tar.gz"
      sha256 "5a9c5913338c37c5959821abbfd58df47530aef58c671543a515c401a51e3c2c"
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
