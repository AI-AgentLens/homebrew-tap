cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1314"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1314/agentshield_0.2.1314_darwin_amd64.tar.gz"
      sha256 "1d710b5867a595683aaa591e571f3905c4b719983e8c7ec776c810c1ca71365c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1314/agentshield_0.2.1314_darwin_arm64.tar.gz"
      sha256 "343be1ae6392b6d057760ca37bf4821cf363e0c8ad97fc61060c02369611d692"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1314/agentshield_0.2.1314_linux_amd64.tar.gz"
      sha256 "12bbcf3647d7a4c38cf41e6821286816574fb953152bd3385091fd775bdaa0ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1314/agentshield_0.2.1314_linux_arm64.tar.gz"
      sha256 "76e53f0dc31dfa791b36b0df8c641beb8af33e3729ea9d7140d53e20225f10ad"
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
