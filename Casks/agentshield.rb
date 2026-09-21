cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2214"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2214/agentshield_0.2.2214_darwin_amd64.tar.gz"
      sha256 "f797712cb556dfea3cf9535f840d87fecca81e64a2a1b249c15ff28272701052"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2214/agentshield_0.2.2214_darwin_arm64.tar.gz"
      sha256 "93de928f2dece57e6832c75674e19e51bfe2ab28b3af785d82ee314438f25db6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2214/agentshield_0.2.2214_linux_amd64.tar.gz"
      sha256 "824f0bcdaa6853e98bd2258ea8e3c9a93ebe27bbabe41f512da0de5d1f66f837"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2214/agentshield_0.2.2214_linux_arm64.tar.gz"
      sha256 "59b77efb591adb0138c36a4718f351ff31c930f7712959567af1c65284a9c72f"
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
