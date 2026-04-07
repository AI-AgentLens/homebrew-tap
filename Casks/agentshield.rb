cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.453"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.453/agentshield_0.2.453_darwin_amd64.tar.gz"
      sha256 "b08225c5d0fba0a71c2e3e10b762128e44b03eb6a002a4e24bd006f2e3c4fb25"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.453/agentshield_0.2.453_darwin_arm64.tar.gz"
      sha256 "479c88eb00f175874063ba873e94b573fd6a4283a6706598c358bd42011e77f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.453/agentshield_0.2.453_linux_amd64.tar.gz"
      sha256 "ceaef5709bba90878f22b6e4efbbc8c2bbbdd6579e0c88aec564e530f728cdcd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.453/agentshield_0.2.453_linux_arm64.tar.gz"
      sha256 "c9239ceaa945fb0bdd1b77d04d4da2f6893f64463dc401a372be1fb79ea66e9a"
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
