cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2124"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2124/agentshield_0.2.2124_darwin_amd64.tar.gz"
      sha256 "252ee42fead0f109ab4bb43683eb924330e3dd95d0c9fee86894edad04e933f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2124/agentshield_0.2.2124_darwin_arm64.tar.gz"
      sha256 "906363328b8de991aade35614cd999c08ad33da1cf6e0495745bf12ecb9a5318"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2124/agentshield_0.2.2124_linux_amd64.tar.gz"
      sha256 "040d25ff2c6dac279111621fb9578b4ba97c49baf6c75bd72c2314be426b7a17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2124/agentshield_0.2.2124_linux_arm64.tar.gz"
      sha256 "3d9e646698b8bc7471971a5b1da501fcf743e6634cff0fb27a7ec238ba7da5c9"
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
