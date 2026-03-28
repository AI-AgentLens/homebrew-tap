cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.166"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.166/agentshield_0.2.166_darwin_amd64.tar.gz"
      sha256 "973a5c06760132c7ce091c4b49a3d3589caf074979b1ff35bec1980090c145cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.166/agentshield_0.2.166_darwin_arm64.tar.gz"
      sha256 "8d09ad57ddad2d4af465d727fca702c535f33c23f7b0b638e3e6526691e81f7a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.166/agentshield_0.2.166_linux_amd64.tar.gz"
      sha256 "d622131fc9d210a9c7056357f964cca53c07de30840d596bf9df00ca27b63420"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.166/agentshield_0.2.166_linux_arm64.tar.gz"
      sha256 "6f450c16d8ef4b7091a140bf6c883ce727353b623480b8aeb6297fcd073e803b"
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
