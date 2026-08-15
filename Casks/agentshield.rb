cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1864"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1864/agentshield_0.2.1864_darwin_amd64.tar.gz"
      sha256 "4df038ccbf064ef7053eeba6f711917698685d9df9b28c030e8c21781fd7516d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1864/agentshield_0.2.1864_darwin_arm64.tar.gz"
      sha256 "69016dea3f82a0d5beefe0e8a791f5a1f7c91209f637e20fa631ee0c4a41fc0c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1864/agentshield_0.2.1864_linux_amd64.tar.gz"
      sha256 "9626fac34c349d6afb0b4d574af02793dfc03b42ca08acc8aa377142d07abe7c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1864/agentshield_0.2.1864_linux_arm64.tar.gz"
      sha256 "36ea59ecafcfb0bd15fb8ae1b7d44c385246958d962ec6908de16ce0d40e6831"
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
