cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2346"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2346/agentshield_0.2.2346_darwin_amd64.tar.gz"
      sha256 "f73e0eb2c57e6ce74727881141bf3f45c52db458d769e524ee0a1003b72846ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2346/agentshield_0.2.2346_darwin_arm64.tar.gz"
      sha256 "1701c58f0288a759bc6de05f097be9cb7fb3398728eb9aa4ac9fcbd6144256d4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2346/agentshield_0.2.2346_linux_amd64.tar.gz"
      sha256 "c1cd23693e2eeba7fad81d935634f5360e0082f3b4af849da2a52bd894ee06b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2346/agentshield_0.2.2346_linux_arm64.tar.gz"
      sha256 "046629a53b05432925baa041c1a2dbeb0ccfe9abe95081889ea80e9fb86501d3"
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
