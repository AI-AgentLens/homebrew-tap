cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1803"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1803/agentshield_0.2.1803_darwin_amd64.tar.gz"
      sha256 "92ca396b08ea74e05a9afd4a8669bd67173732a26c43abcf057b6bdf288a161e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1803/agentshield_0.2.1803_darwin_arm64.tar.gz"
      sha256 "f59311eef02c7504d5e789482e004aec4db8978360b6ca61bca900f56f0350bb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1803/agentshield_0.2.1803_linux_amd64.tar.gz"
      sha256 "0ffdf125917c0c5686df09f993df0b1bd01c73760d8830fb1e31fa26abe6b878"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1803/agentshield_0.2.1803_linux_arm64.tar.gz"
      sha256 "a16c8dc9d8e8788f167460deb7d0dd393f66873fa5fdaf234516d6554a03fa0f"
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
