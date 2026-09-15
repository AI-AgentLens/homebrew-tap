cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2147"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2147/agentshield_0.2.2147_darwin_amd64.tar.gz"
      sha256 "57660e9d8893b1e744ff3d12ca90a8aa79d818cda88ff7153b369f1826cc3c84"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2147/agentshield_0.2.2147_darwin_arm64.tar.gz"
      sha256 "bd01e1044c1df710ff9e069c9c3b7a7c07b9008b211cc39dd329da8f3fbd749d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2147/agentshield_0.2.2147_linux_amd64.tar.gz"
      sha256 "9202c48792e730f75496565a920d38c45eef20dd3048ab5bd624278d601c20ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2147/agentshield_0.2.2147_linux_arm64.tar.gz"
      sha256 "0e3b68ca69076c17ca108409b2b2bcf8bf48b0b54ca60bfb754998536a261ebb"
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
