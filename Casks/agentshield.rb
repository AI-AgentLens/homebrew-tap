cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2287"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2287/agentshield_0.2.2287_darwin_amd64.tar.gz"
      sha256 "b60df1d409ed3972847c663fde3a0f4da23f5cfa911a074796b3e1b8ae0d2e93"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2287/agentshield_0.2.2287_darwin_arm64.tar.gz"
      sha256 "215804eac0163e75a250672869fff3b0a8586a5a5bac856311ac1dc9f582b8c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2287/agentshield_0.2.2287_linux_amd64.tar.gz"
      sha256 "a741a2b8e2f92f742428005067688724aa09600e6ab27551f84c28dd21364182"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2287/agentshield_0.2.2287_linux_arm64.tar.gz"
      sha256 "0b6851da934ccac413fd7b669700294a4d4e225a68c14a8a8082b2c8be37c850"
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
