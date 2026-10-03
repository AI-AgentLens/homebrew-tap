cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2329"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2329/agentshield_0.2.2329_darwin_amd64.tar.gz"
      sha256 "a64675f4654adabc75e0fe5a9b3c310ed306cc8b9553f436388a05af2c262d35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2329/agentshield_0.2.2329_darwin_arm64.tar.gz"
      sha256 "488047dbae8be49e47a343b9830064feb33661004acd530f3be6598fd887969c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2329/agentshield_0.2.2329_linux_amd64.tar.gz"
      sha256 "5013f83fd64fe705915708abe0e1a03de7075542048991701227af4d5d053892"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2329/agentshield_0.2.2329_linux_arm64.tar.gz"
      sha256 "f994488dd90cbd614017e464aeaa43841b7601b260bb301bed934f14d2d45fc2"
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
