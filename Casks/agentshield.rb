cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2162"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2162/agentshield_0.2.2162_darwin_amd64.tar.gz"
      sha256 "8ce9b5b1d5ad00862b0ede559da762b758f1eae0592a2035cd1d2b7338ae9228"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2162/agentshield_0.2.2162_darwin_arm64.tar.gz"
      sha256 "9b6c3d6b0e8b08f45569a6e4d49e09913fdb2a391206a53f631fc805494b73fe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2162/agentshield_0.2.2162_linux_amd64.tar.gz"
      sha256 "3b174150529c9a4206be13f6bad63244a87f2c1bf4136baefbb8be7b8f541ff6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2162/agentshield_0.2.2162_linux_arm64.tar.gz"
      sha256 "dce242cee70fdb04f597c933fa2322253d40457ae5399efccf0d6073aa7f2d1f"
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
