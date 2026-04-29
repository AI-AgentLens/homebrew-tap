cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.819"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.819/agentshield_0.2.819_darwin_amd64.tar.gz"
      sha256 "01f6d4c84a7419c1967eee9ab03c5686bb074762da8ee97e28f57819f4f3f4dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.819/agentshield_0.2.819_darwin_arm64.tar.gz"
      sha256 "23ce881941c594e369512a47f442e5190f8f1a49cc50584ddc499caf0784365a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.819/agentshield_0.2.819_linux_amd64.tar.gz"
      sha256 "eea91a865d190a116ca066bf0908b432d3792d61bfbbdec366419371292b4174"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.819/agentshield_0.2.819_linux_arm64.tar.gz"
      sha256 "513ddc55f3c87af2df7b2aa51dca72b0fb54e1cf164c312c4e9f911dd1c4df36"
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
