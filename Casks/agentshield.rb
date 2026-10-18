cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2460"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2460/agentshield_0.2.2460_darwin_amd64.tar.gz"
      sha256 "6d0d7b92f4668a90b5f98875e005421bca174e0368dee9136623223d22fc84a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2460/agentshield_0.2.2460_darwin_arm64.tar.gz"
      sha256 "e2177330cec7493ef3bf601687dee9b1aa886f6f24c5ed7425a2305e1478ebf9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2460/agentshield_0.2.2460_linux_amd64.tar.gz"
      sha256 "7ab1247dd6fb1492ec094b27f15b10ca0f7a4c9788c284feee3a84b1faee663d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2460/agentshield_0.2.2460_linux_arm64.tar.gz"
      sha256 "714dfd9bc9785a34a8abd7138c67037aab8f53521d1175a8ea22c3f44f8c9bc3"
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
