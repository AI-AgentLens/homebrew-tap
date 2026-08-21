cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1916"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1916/agentshield_0.2.1916_darwin_amd64.tar.gz"
      sha256 "93d4b9c471c120eaf0086a6d40e2bf5bfe4d0bc960dacb3a32e40d987598db21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1916/agentshield_0.2.1916_darwin_arm64.tar.gz"
      sha256 "6ce1c5031ebff46242dda3460a904ddd6fc383c94d060fdad1435733b83b0296"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1916/agentshield_0.2.1916_linux_amd64.tar.gz"
      sha256 "b391c0bc1aef54f59ebf6cfb70209de5d3810b3b966ba6e841c807679eaac384"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1916/agentshield_0.2.1916_linux_arm64.tar.gz"
      sha256 "fd0163c7134a420c5e13d8cc2b15383d10c8971ac426afb2d67b8633800b5acf"
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
