cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1702"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1702/agentshield_0.2.1702_darwin_amd64.tar.gz"
      sha256 "6f6f622d477328977b709d59b4b601f08849c0a56ebba68e194d134152d19d97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1702/agentshield_0.2.1702_darwin_arm64.tar.gz"
      sha256 "bfee741d5236c95d9086a24b875d514a39184d698915a5de760c0f2d6e0d9e73"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1702/agentshield_0.2.1702_linux_amd64.tar.gz"
      sha256 "6c2c64e40f1df3188c74d33b0973d82b8874e71ffa984e1114c3f78521df542b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1702/agentshield_0.2.1702_linux_arm64.tar.gz"
      sha256 "11a6d71a076b07e7f86dc5c20d77ad2c5760603b024091056e333e9302195e36"
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
