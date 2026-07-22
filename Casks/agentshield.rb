cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1711"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1711/agentshield_0.2.1711_darwin_amd64.tar.gz"
      sha256 "c465d75fd4a294986f168814df0493058e42cfb956895d8fb8491d53634a72e1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1711/agentshield_0.2.1711_darwin_arm64.tar.gz"
      sha256 "bfd68e85e57369bc694981bdd9d5a67b563ac7f72cb8196151a53c3b92822b58"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1711/agentshield_0.2.1711_linux_amd64.tar.gz"
      sha256 "7cfa61a8748b6807766ffff0c63fabb446b9aefd99f7050eb5af307cb162beae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1711/agentshield_0.2.1711_linux_arm64.tar.gz"
      sha256 "63541dea7a5e6ccb61aff66125d0e9ed3045e3cbaa0193628b39ce8fdb338512"
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
