cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.549"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.549/agentshield_0.2.549_darwin_amd64.tar.gz"
      sha256 "75475133c3c26f45eaa8a1b2b9ba4f0740e5d28a1a91b7e4a23ed78565e1c205"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.549/agentshield_0.2.549_darwin_arm64.tar.gz"
      sha256 "8463e83d6755c82d4a61210f1ea8f16e1de494025ef48e8e898b1173c121cbd0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.549/agentshield_0.2.549_linux_amd64.tar.gz"
      sha256 "26e6a4873cf2b73567108516884288ac216f6046f466f3da3400b3206c66172e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.549/agentshield_0.2.549_linux_arm64.tar.gz"
      sha256 "3218cf5baa1e9471a9d043c8a63186b42b7c7940437b6c1078c51caf99f5b726"
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
