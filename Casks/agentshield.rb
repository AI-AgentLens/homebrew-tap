cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1237"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1237/agentshield_0.2.1237_darwin_amd64.tar.gz"
      sha256 "513f34059d18894a7d89246db2c5a65b8868b72cf36b9cb983c11cf69aa36145"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1237/agentshield_0.2.1237_darwin_arm64.tar.gz"
      sha256 "fdd8bfdca6f02db9c0464ef6b5aa35e4165d3ff10e4b35905d3e98d5426be3cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1237/agentshield_0.2.1237_linux_amd64.tar.gz"
      sha256 "6dd550b48a3ac6a03f0d33a3e602eaa82fa77d8b5699b993d179179c99a85f9f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1237/agentshield_0.2.1237_linux_arm64.tar.gz"
      sha256 "7c1bbc2a99f20b4b7e8b7c4dbc2c89d2ebd497cdb9e5b31f8d894d5c43655dbb"
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
