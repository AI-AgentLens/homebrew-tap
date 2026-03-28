cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.160"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.160/agentshield_0.2.160_darwin_amd64.tar.gz"
      sha256 "3ec34122fcf64ca916c41e5ad644fa5e54079934117eedee2d04ab26b0691da0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.160/agentshield_0.2.160_darwin_arm64.tar.gz"
      sha256 "392297102e5aa1f7601cafccdec2cb60eb3784c07828715859f4e8ad1473dc21"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.160/agentshield_0.2.160_linux_amd64.tar.gz"
      sha256 "4e8c80aeafb7998a5aaa77cdc951bfb4a147d430ea5ecffe99edbc2806a62a5e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.160/agentshield_0.2.160_linux_arm64.tar.gz"
      sha256 "572c2048afd5338d192b1549396cee65aa6c48cbb536a17de9a564c796f722aa"
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
