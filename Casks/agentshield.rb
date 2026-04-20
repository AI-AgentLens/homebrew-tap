cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.667"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.667/agentshield_0.2.667_darwin_amd64.tar.gz"
      sha256 "a8636cd0f18a7be48022565118c67d0d73db17201e946666621fb60d7bc336b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.667/agentshield_0.2.667_darwin_arm64.tar.gz"
      sha256 "63f403f9ca2c820c6b99555678510c53aeb57a8070531fe622c0242a5f28ce8d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.667/agentshield_0.2.667_linux_amd64.tar.gz"
      sha256 "935c0a1e9bb3b725fc7543edf15cc642f7d88c4bd42282fd5c69facc3ee7c30f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.667/agentshield_0.2.667_linux_arm64.tar.gz"
      sha256 "1b6571e3ef966c71a66f44081824744b9d7fd8ef288caa605d536904e6b9c67e"
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
