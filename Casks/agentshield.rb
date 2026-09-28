cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2282"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2282/agentshield_0.2.2282_darwin_amd64.tar.gz"
      sha256 "4aba856e6c18c891a37920b1319a8aec94fc7c992f86bdb1a6e5f9072b6515fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2282/agentshield_0.2.2282_darwin_arm64.tar.gz"
      sha256 "67ded63e3d88a15a47ff4481161967a6d891427b6a142e47230d16854dfc7d89"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2282/agentshield_0.2.2282_linux_amd64.tar.gz"
      sha256 "143d3257d9f93b7710d9506a5f15caea549b3855258ae24eb82c68807222e391"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2282/agentshield_0.2.2282_linux_arm64.tar.gz"
      sha256 "08d326ebf5ce66817d3bc3d3fe73ac9323e6e7664d5aa5c85ab2f9c1b486e876"
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
