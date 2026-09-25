cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2251"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2251/agentshield_0.2.2251_darwin_amd64.tar.gz"
      sha256 "0467606e18821be66e4a4bea64666b2435e121ed5bc235a5927f78725e3d972a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2251/agentshield_0.2.2251_darwin_arm64.tar.gz"
      sha256 "d35110cd39986eef676eac12ac0ff8053461e6e3f055bb156f769c70a8aa2b20"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2251/agentshield_0.2.2251_linux_amd64.tar.gz"
      sha256 "a9b9388280e3b8e972c97fbce5ca96288e849304d58ebb232dd7d7b9b2deaeba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2251/agentshield_0.2.2251_linux_arm64.tar.gz"
      sha256 "6f65093a7f4c9531b4b0519641006f8d27831b606d1bbff028fcde25de054bec"
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
