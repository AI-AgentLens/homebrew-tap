cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.615"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.615/agentshield_0.2.615_darwin_amd64.tar.gz"
      sha256 "e6058a2975058dcdb30386abecea65de7ba235bf0ae44e6a3398dd02d2f2c26d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.615/agentshield_0.2.615_darwin_arm64.tar.gz"
      sha256 "a5231dc4f2603a5bc4a724dd994bf4040b525da3b29780acfb87eb0cbb57f75e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.615/agentshield_0.2.615_linux_amd64.tar.gz"
      sha256 "0541ea6657b0a1ad4f82e2a2ee99d626d77d938406f30eb1ae613e7d20ad99b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.615/agentshield_0.2.615_linux_arm64.tar.gz"
      sha256 "d30106e7493f2a449e0f5b0ef26995a8a084c867ccba082ce22b94326e4ab5ec"
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
