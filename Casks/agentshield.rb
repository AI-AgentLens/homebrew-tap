cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2135"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2135/agentshield_0.2.2135_darwin_amd64.tar.gz"
      sha256 "419b4cceb12dde68f53601b70676e5d878a30bfdf2c2b2d4c84fda0517b67c77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2135/agentshield_0.2.2135_darwin_arm64.tar.gz"
      sha256 "c558c7bee5d708d4853bb53bf0d34d2eeda26e02bfa0a1df9f1a3f810433508b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2135/agentshield_0.2.2135_linux_amd64.tar.gz"
      sha256 "0505e782932f05245df2087c122d4b54c903f56380338d7b5f6119fce75edc62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2135/agentshield_0.2.2135_linux_arm64.tar.gz"
      sha256 "86291964d39896819787bd15ffe79d9e55be421c1f6d16b75463367d9f6a94da"
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
