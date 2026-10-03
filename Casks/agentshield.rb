cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2324"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2324/agentshield_0.2.2324_darwin_amd64.tar.gz"
      sha256 "a4ac3be60ade7422b3f83b0db0179600f7009e0ff3effff393b0d0c149a6e185"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2324/agentshield_0.2.2324_darwin_arm64.tar.gz"
      sha256 "2c9c82462accdec120bcffc921ad4e73860dc9c3de82ecaf021803a7482ca1ad"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2324/agentshield_0.2.2324_linux_amd64.tar.gz"
      sha256 "d0a2a9dc9aacbbbdb445ee82617495b0d86d3be37cedd0a7e7b68df288a4e727"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2324/agentshield_0.2.2324_linux_arm64.tar.gz"
      sha256 "10d7e933afe8ffb84e67837dd209f70f29002f8a9b407b020a26b2af92c17148"
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
