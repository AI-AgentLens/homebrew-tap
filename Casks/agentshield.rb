cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2250"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2250/agentshield_0.2.2250_darwin_amd64.tar.gz"
      sha256 "5debf7f9ac9a56984a8494ac970c0a9078f4ca22a0b3d093ab82049d19ac1718"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2250/agentshield_0.2.2250_darwin_arm64.tar.gz"
      sha256 "aa3d5c18fabb9a873ce09179523c2d2aaf0e9a62ae7f123c9084062655ba2457"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2250/agentshield_0.2.2250_linux_amd64.tar.gz"
      sha256 "25815cf84ec32a77d84cd9151f8266180ed63e8b95729ddaaf29411ca10f9d10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2250/agentshield_0.2.2250_linux_arm64.tar.gz"
      sha256 "6ecd62f8762c9a8edf6eab1bc542b7292e0c7abfa7119f925846bd868dc8bbd2"
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
