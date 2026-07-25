cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1727"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1727/agentshield_0.2.1727_darwin_amd64.tar.gz"
      sha256 "269e66fa63b25408e3dbfc02a6ed648c6a3fa2db6e646ca4325c54c07ba71271"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1727/agentshield_0.2.1727_darwin_arm64.tar.gz"
      sha256 "6abd4ee53a46fbc973dfed8df0d300608d70ce472c9ab67457d9d926a3c00b94"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1727/agentshield_0.2.1727_linux_amd64.tar.gz"
      sha256 "e790b92d560353735f929b74db09c991e62d566bfeed07a218b38a98fcfaeba6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1727/agentshield_0.2.1727_linux_arm64.tar.gz"
      sha256 "5fe680eca3911c94b20ebb9a61aa33a1ed8db022767a271706bf6513249a5900"
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
