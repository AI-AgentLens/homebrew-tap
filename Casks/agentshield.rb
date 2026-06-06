cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1222"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1222/agentshield_0.2.1222_darwin_amd64.tar.gz"
      sha256 "df554b6aecd0f48d522fe493062ecce4abde6eac0813885c1531bb73085905f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1222/agentshield_0.2.1222_darwin_arm64.tar.gz"
      sha256 "5d3bc818cddb5bc9a429ed2f6c97c6e944643757d91ac4dd132d144d8d80271f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1222/agentshield_0.2.1222_linux_amd64.tar.gz"
      sha256 "2d53b1b7b5b567515b8a61243facb3ad22162b865f6b7519bb3b83d61213bfe6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1222/agentshield_0.2.1222_linux_arm64.tar.gz"
      sha256 "1dd55aeb4b380093a9d104d296bb28bd853871f8b709db4353d01fb691aff465"
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
