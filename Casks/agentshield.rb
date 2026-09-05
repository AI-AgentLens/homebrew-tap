cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2045"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2045/agentshield_0.2.2045_darwin_amd64.tar.gz"
      sha256 "839a569b86ec95d0190aebe0aea18085bda96abb77596848ecc66507ff5c2053"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2045/agentshield_0.2.2045_darwin_arm64.tar.gz"
      sha256 "79ae2ed3158fefa0b2e9da04340b3373d3adf7b17ecf6dec072e23d3fbe3151d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2045/agentshield_0.2.2045_linux_amd64.tar.gz"
      sha256 "b7d108f93d55500871ca2c3c1edb896660dd43d08e9746bc9c8f913832ede862"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2045/agentshield_0.2.2045_linux_arm64.tar.gz"
      sha256 "9fa17a9cea24ad4bd37ce092dea32f6f3f490afbe37ad9667b46095e8ae7316b"
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
