cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1692"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1692/agentshield_0.2.1692_darwin_amd64.tar.gz"
      sha256 "0189bae6a4cfce34a21b0a4fb6c0744092cf04a609c91f652486a62b02fc8c0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1692/agentshield_0.2.1692_darwin_arm64.tar.gz"
      sha256 "b908b6bd2b1f1b57fea1320aacba6dd7f3a14d477ecfebba236c7775f94d7530"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1692/agentshield_0.2.1692_linux_amd64.tar.gz"
      sha256 "eff144d35e817df1a3de451281956b82f321129f9b2c7840a23cd066b0d19d8a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1692/agentshield_0.2.1692_linux_arm64.tar.gz"
      sha256 "c577b26c9362dd26e5e813cf4e95f4c90475da9084a8f25194ac840fa90d6816"
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
