cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.687"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.687/agentshield_0.2.687_darwin_amd64.tar.gz"
      sha256 "396511edc9908dc1eefe9fb67296fcc939fd5a832ce4d32d92fd15496a333d43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.687/agentshield_0.2.687_darwin_arm64.tar.gz"
      sha256 "76c0d52ab836ffc27c6583371038b13584ebc95c67ee057c8152ba4c3f26d8ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.687/agentshield_0.2.687_linux_amd64.tar.gz"
      sha256 "30423fe1e903b97a31cd6d1eb669681f7059d8966229f35ae887528ac63d0d97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.687/agentshield_0.2.687_linux_arm64.tar.gz"
      sha256 "4a9ad24ba2e8ffc4b1205c080f934af5b5454dc4d1aab7b71e232e3f2c272f26"
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
