cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2411"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2411/agentshield_0.2.2411_darwin_amd64.tar.gz"
      sha256 "ceea215dd405f0012033fd82f5556208dc60a2c43960ef903bdfc64b5f8f8b55"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2411/agentshield_0.2.2411_darwin_arm64.tar.gz"
      sha256 "9583b65eb53324357ebf0d649a69e997288107ae14628b306d95dffa32a8b875"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2411/agentshield_0.2.2411_linux_amd64.tar.gz"
      sha256 "9835cb74839122f4e5f4e6283de8828726ec71667b11030a74146f48127b1041"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2411/agentshield_0.2.2411_linux_arm64.tar.gz"
      sha256 "f191126844a12e540e7c5e1ae52d9d22c32bd820443c11533406b37f62051cc0"
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
