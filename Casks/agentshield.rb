cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.928"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.928/agentshield_0.2.928_darwin_amd64.tar.gz"
      sha256 "c13a74170f9726acd1f06d3573c9acbf617c5cdb1a033f98910ca78b23198223"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.928/agentshield_0.2.928_darwin_arm64.tar.gz"
      sha256 "fb88559a23248063a16a0e603a0fd049189abbd5cdbd61b1e44dfd7ca9e20433"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.928/agentshield_0.2.928_linux_amd64.tar.gz"
      sha256 "c385083349570d0df5a8f29f23a40f84dcb122717630006d9dd333c02b1cf145"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.928/agentshield_0.2.928_linux_arm64.tar.gz"
      sha256 "2350ebc9a745b3519ae509b53efcbccc20347a9b09359cca3e4f3b2fa21e35f2"
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
