cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2153"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2153/agentshield_0.2.2153_darwin_amd64.tar.gz"
      sha256 "52191a6b36ee9fe3d5371231dbff13d9b39b11b2252e46f3f34adb9136472d60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2153/agentshield_0.2.2153_darwin_arm64.tar.gz"
      sha256 "6537852a72362804576873b9ff53e864468452fbc78ed45722715745225186c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2153/agentshield_0.2.2153_linux_amd64.tar.gz"
      sha256 "23ce47168dc1a187bf78d3ceac2f757ec34b3cbd94c267e7de031a75a4738c37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2153/agentshield_0.2.2153_linux_arm64.tar.gz"
      sha256 "9409227bcd93d8bfad17a745eb5f751a0608c55d350e95147f77eba80e80a557"
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
