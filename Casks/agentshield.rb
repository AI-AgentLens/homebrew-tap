cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2347"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2347/agentshield_0.2.2347_darwin_amd64.tar.gz"
      sha256 "c183442090efa1b4a5a5b402ed69af72784c4ae27bdf85b8964244d63db4a2ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2347/agentshield_0.2.2347_darwin_arm64.tar.gz"
      sha256 "24e82fd9851a3f92cf8a6908933cf9182d23b81c67f97f65a16f75e913f1f4ca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2347/agentshield_0.2.2347_linux_amd64.tar.gz"
      sha256 "4b1f4a0f4267e3cb2194018a1cb33914edfbd05a6d8f7c4b16cbdf708dd44b23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2347/agentshield_0.2.2347_linux_arm64.tar.gz"
      sha256 "0352e08050ead79072e4ea2abccdd3e157cf80f11837eeb16768b2c82de3c38f"
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
