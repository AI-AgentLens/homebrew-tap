cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.600"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.600/agentshield_0.2.600_darwin_amd64.tar.gz"
      sha256 "40c3ab26476c0e3e2c66114bd0f8ed9502685690c93317636ea5bb3558acae20"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.600/agentshield_0.2.600_darwin_arm64.tar.gz"
      sha256 "d2c44ce40300c94d5e38f90152dbd058f181e15f6e99d2f0ed701051178b7bc6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.600/agentshield_0.2.600_linux_amd64.tar.gz"
      sha256 "f9e08b8a7169e592becce9305882172d24901d2a91f1d8801943eaae05a328dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.600/agentshield_0.2.600_linux_arm64.tar.gz"
      sha256 "bd9b3b22c0468a79b47bc84559630db316f41d5cdb1d8fbc3b0a3bf02abf1e56"
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
