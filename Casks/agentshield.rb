cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2127"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2127/agentshield_0.2.2127_darwin_amd64.tar.gz"
      sha256 "f61bafb877b247fae57f61d967f8a6fb086e0a951ab3c01a0e6869c3e8c55a14"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2127/agentshield_0.2.2127_darwin_arm64.tar.gz"
      sha256 "6bba77d8315a240950def31bbdacc1ffc4b0ef152ee058371477db50c9ea6145"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2127/agentshield_0.2.2127_linux_amd64.tar.gz"
      sha256 "bb80815702bf2039d596e197583ba9acb54a3cc8e58fcb873b28be646f60e9d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2127/agentshield_0.2.2127_linux_arm64.tar.gz"
      sha256 "7fcc5d3df88365e26b997e205a8e2c08291e18a772fbfaaeb8674f2a00a79f0b"
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
