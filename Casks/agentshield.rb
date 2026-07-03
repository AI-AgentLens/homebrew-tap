cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1543"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1543/agentshield_0.2.1543_darwin_amd64.tar.gz"
      sha256 "c5227e6cd4df656dd298e5afefcdb85a8a6eb1507997d6a2305ce7b7ed4c24cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1543/agentshield_0.2.1543_darwin_arm64.tar.gz"
      sha256 "1642b44df43d573939a30e958534d8d657818e357c801ce4bc9fbca8927b1288"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1543/agentshield_0.2.1543_linux_amd64.tar.gz"
      sha256 "5cee31fa3a9c2f662a1e3b609a3a8da5a9c3caeaefa4bd2bc10bcdb87cb7a8cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1543/agentshield_0.2.1543_linux_arm64.tar.gz"
      sha256 "e7eccaf4dcb61e55b2e472f1ec52efb0b40a782d88f35fc23815945cec615b06"
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
