cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1663"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1663/agentshield_0.2.1663_darwin_amd64.tar.gz"
      sha256 "4a053d7aea34f833a4d74f1e3aedc7847ada1df2f898ce025c498966201beaae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1663/agentshield_0.2.1663_darwin_arm64.tar.gz"
      sha256 "c92f0c259cf6a642e56503dd244f6373f5e45238ef55fced22610df35a07c49f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1663/agentshield_0.2.1663_linux_amd64.tar.gz"
      sha256 "d456b8b9bc2be50ca25a8ed76edd91f412e084b2e5c813dc2db4d02c317cbf57"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1663/agentshield_0.2.1663_linux_arm64.tar.gz"
      sha256 "a04d827715cf8ae74622e36ad5852973320665c63aa3b5fa30c208769be70d0e"
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
