cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1426"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1426/agentshield_0.2.1426_darwin_amd64.tar.gz"
      sha256 "20cd47ef80300bda971cfff0e02e3d534c6675dfe9907bfdc03abc5cded90c72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1426/agentshield_0.2.1426_darwin_arm64.tar.gz"
      sha256 "dc458ba9cdeacdc8c9502ff7d21da205834a223ee4d2d78d7818163bc2a94b32"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1426/agentshield_0.2.1426_linux_amd64.tar.gz"
      sha256 "d9f72b4db769abd74c236b3818a0587d4843970024de00987a0289805a20bdc0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1426/agentshield_0.2.1426_linux_arm64.tar.gz"
      sha256 "ec131ff8e035fb5d8203f330580bcb556b274333d0f78ceeeff68f89b152daa2"
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
