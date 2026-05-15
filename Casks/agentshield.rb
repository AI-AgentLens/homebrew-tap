cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.985"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.985/agentshield_0.2.985_darwin_amd64.tar.gz"
      sha256 "84c1358cad22b5acdb3091d8c8ddb959e6399f268f37308d3965093c5b666293"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.985/agentshield_0.2.985_darwin_arm64.tar.gz"
      sha256 "7272e0f51cf86fcaf28621d9e8c7df740c612730c29ca2f1781e58d23c8c77b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.985/agentshield_0.2.985_linux_amd64.tar.gz"
      sha256 "9a09d1066d6306750746056e44acf9a86ad7b044e2f6fb81c1e9ff9f7ff12534"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.985/agentshield_0.2.985_linux_arm64.tar.gz"
      sha256 "5644b43767d4c7e2ad6421eb47396f5d3d792fd4f30784816ba6dfdbb5720df8"
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
