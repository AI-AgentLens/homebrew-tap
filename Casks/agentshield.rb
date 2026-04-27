cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.769"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.769/agentshield_0.2.769_darwin_amd64.tar.gz"
      sha256 "f2f94415a1907e5f572c267f2cd59b4166faf72194e2a7a0a73f07c4d32a4b4f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.769/agentshield_0.2.769_darwin_arm64.tar.gz"
      sha256 "eab8a9e340c4c7890ede8e2f000daa1a78fbb39a671a53c24aa7c8f7d79d82d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.769/agentshield_0.2.769_linux_amd64.tar.gz"
      sha256 "c8cb945e926a304ca6682455392f6c28ba2e2c6490ceec255cae6c03f77155fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.769/agentshield_0.2.769_linux_arm64.tar.gz"
      sha256 "e7ca5268dec7c93ac77a63a3929d291cc0ed995f5e6214569c66b1856cc9d9f1"
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
