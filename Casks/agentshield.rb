cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2396"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2396/agentshield_0.2.2396_darwin_amd64.tar.gz"
      sha256 "e8c6362e75fdabd2ec891f5725f2806b4fabecd2b4096f06e0c6ea768a004b7c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2396/agentshield_0.2.2396_darwin_arm64.tar.gz"
      sha256 "d70bd4ed946e6cf721379edb45e0b207baa8d62190b59628b18b4eee6d0317d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2396/agentshield_0.2.2396_linux_amd64.tar.gz"
      sha256 "23a802b3dd5817bc5cd30f35902fecfa763045178012e85dfab29f2f227b3552"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2396/agentshield_0.2.2396_linux_arm64.tar.gz"
      sha256 "2bf72f9c2c055510f444052650ce1d8c0f2dd1ff38ede72204616d1faf1a893d"
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
