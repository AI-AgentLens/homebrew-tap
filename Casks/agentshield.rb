cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1309"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1309/agentshield_0.2.1309_darwin_amd64.tar.gz"
      sha256 "fd4c53ba9f35d8aaf15d63ab0b2612ae318eb657e0160cc66f9f4b07d3de8d89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1309/agentshield_0.2.1309_darwin_arm64.tar.gz"
      sha256 "f4f397f4061559fce3a1617d1f5b76ab86b0046f418556531aa2ab2cf9458078"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1309/agentshield_0.2.1309_linux_amd64.tar.gz"
      sha256 "4eca270dedbe2b722035cb8f27fe2fabe1851caee5d821ecce403133a2561957"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1309/agentshield_0.2.1309_linux_arm64.tar.gz"
      sha256 "ae482891f737fc9650c43f3bf12728d1202a9b07bd91b03f790cfd4c32b257f0"
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
