cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2078"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2078/agentshield_0.2.2078_darwin_amd64.tar.gz"
      sha256 "24e9d9a97b346259a4901e953f4ff93733fe93421c530eb4f0af78bf7115a7d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2078/agentshield_0.2.2078_darwin_arm64.tar.gz"
      sha256 "463824ab5018ce86185b974729483039a0316b4bfbe1bb0d97d158e89d34d41a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2078/agentshield_0.2.2078_linux_amd64.tar.gz"
      sha256 "63b55011044f19825b519fdd801ca5e5101dd8710cc2e1c34d5af4c05ddd0124"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2078/agentshield_0.2.2078_linux_arm64.tar.gz"
      sha256 "bf123ab06117d81da2f22eac5b067ad17675eae52e5e65d6e61d2a8b305d6d7e"
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
