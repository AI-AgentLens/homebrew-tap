cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.190"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.190/agentshield_0.2.190_darwin_amd64.tar.gz"
      sha256 "37112bf801e0ac152b2f5d0da5afa3921329f62daba1654e4546c16cb139c4a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.190/agentshield_0.2.190_darwin_arm64.tar.gz"
      sha256 "741108f0c0edf8cdfb16c5cb8b7c4729d26bc60f81306464f6813c9ef71e46e0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.190/agentshield_0.2.190_linux_amd64.tar.gz"
      sha256 "f7323a676c34bf44ec5f3965335124475bb2eb06bc3ee373a10863bea947b6ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.190/agentshield_0.2.190_linux_arm64.tar.gz"
      sha256 "506549c928dfc177f7cce65f1002afe1f4576592cd12adb2a032a84008486995"
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
