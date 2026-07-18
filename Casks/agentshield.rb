cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1666"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1666/agentshield_0.2.1666_darwin_amd64.tar.gz"
      sha256 "83b874bceb3f7ad6b5baf16d412166463e645080476530d3cdd5b92146e58daa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1666/agentshield_0.2.1666_darwin_arm64.tar.gz"
      sha256 "58920305d0c6a52fe949ff4998f8f1d21701ff7ce5b706d0f004dbc4278a86cc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1666/agentshield_0.2.1666_linux_amd64.tar.gz"
      sha256 "ddc9022a6a47f4016ed03f41b1d2b55ca28ae68df28d03c06b594e0fb5144632"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1666/agentshield_0.2.1666_linux_arm64.tar.gz"
      sha256 "cbaafb570f4dbb2c73a5d7a8dfaab1cbec5f28347c27546908d9a88e2c2a656a"
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
