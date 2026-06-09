cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1258"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1258/agentshield_0.2.1258_darwin_amd64.tar.gz"
      sha256 "33e3609a71371629bedf00cc9b3bf57735fa7cdde8ba5cdd5b8fea790081c092"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1258/agentshield_0.2.1258_darwin_arm64.tar.gz"
      sha256 "36778b2ee8fc8828662eae66f770f3ef7409d739f75b5ecb4757b034b229f9ef"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1258/agentshield_0.2.1258_linux_amd64.tar.gz"
      sha256 "95ffe15edfa182599b31e0e31cabe3c852ce94cf4a0b59a6210924398f80043f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1258/agentshield_0.2.1258_linux_arm64.tar.gz"
      sha256 "29804e4d789f1e2ea71da1b120cf735544d21c21f9b20c26296340f98039603a"
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
