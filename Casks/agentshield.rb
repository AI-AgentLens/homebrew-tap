cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2358"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2358/agentshield_0.2.2358_darwin_amd64.tar.gz"
      sha256 "777a2fe3a426a277dad54f79d006f1282d2758d5b4ea52c728039e245495d706"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2358/agentshield_0.2.2358_darwin_arm64.tar.gz"
      sha256 "4073c989f4c2243d8e8a10ba036445fb3d271a650b1078d1a598949189796589"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2358/agentshield_0.2.2358_linux_amd64.tar.gz"
      sha256 "aa2d846002a6c67420aa969d1c9116c1aeb3eb0cdb75dd3d62c2b9c376b1bb2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2358/agentshield_0.2.2358_linux_arm64.tar.gz"
      sha256 "d0073ccfdae1e6a4c5826123ff4606653ecd45380a12f2c020ce4d61a78af7cc"
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
