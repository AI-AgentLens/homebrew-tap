cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1029"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1029/agentshield_0.2.1029_darwin_amd64.tar.gz"
      sha256 "87e02c654679bcae8ccaaa53dc9d10453ec149c6f9d4a47d98a7b929d99603aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1029/agentshield_0.2.1029_darwin_arm64.tar.gz"
      sha256 "70dfac9fbdea10eb30afaab99df7585b2fc6bece6190150a107de213b4a7282e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1029/agentshield_0.2.1029_linux_amd64.tar.gz"
      sha256 "e1ac1810dae68fdb2ca9c2b60b8f41e604caf4ace36aacf5b54d98bb46bba322"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1029/agentshield_0.2.1029_linux_arm64.tar.gz"
      sha256 "b84d9cdea1fceab340d673e221a4f6512a2100c52ae6c54fdfa27e0071889ade"
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
