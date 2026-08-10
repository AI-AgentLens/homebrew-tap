cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1808"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1808/agentshield_0.2.1808_darwin_amd64.tar.gz"
      sha256 "14dc33d2a857e4cac72c8495541c886d24dd7787f2ea79839184c4b838c78270"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1808/agentshield_0.2.1808_darwin_arm64.tar.gz"
      sha256 "70e862a0f3a295bb447f9488579e7b33f6c26d3627dc4a452f6f14ff8358dbbe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1808/agentshield_0.2.1808_linux_amd64.tar.gz"
      sha256 "36e5fb53bd75cc60be95d804ce6af44f6b0398a59b26e5e7a33ab5bb2e2c3890"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1808/agentshield_0.2.1808_linux_arm64.tar.gz"
      sha256 "7b15619a16f3243b97d31ffec5e23a1242f0d91339fab7b7394a79b236638906"
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
