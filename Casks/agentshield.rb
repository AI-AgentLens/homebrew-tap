cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.482"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.482/agentshield_0.2.482_darwin_amd64.tar.gz"
      sha256 "c22366c505ac940e2cd37786bc59e0e056fc0c069bdd0be7782f92d029119b31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.482/agentshield_0.2.482_darwin_arm64.tar.gz"
      sha256 "17e5a5c037201003a3e1415be10c9bd6c24b19de89ecf0e8e9cb80ba24b5ee09"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.482/agentshield_0.2.482_linux_amd64.tar.gz"
      sha256 "08d6e0e2babf2ecaba3a3e0c1ab6f663d9cd31e36352ac3e30f461d4d1cecbdf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.482/agentshield_0.2.482_linux_arm64.tar.gz"
      sha256 "8d2442aaa15dd94f8fcf4a5c34c06eac494e05a09678bdb120c257b702370fcf"
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
