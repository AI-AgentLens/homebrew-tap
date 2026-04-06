cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.431"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.431/agentshield_0.2.431_darwin_amd64.tar.gz"
      sha256 "0eeaca1398a5f09acb0a81ab83735c186ef83ebc0243cd0efc6f301015dc2ffa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.431/agentshield_0.2.431_darwin_arm64.tar.gz"
      sha256 "e312df2d789412894c95004664bbb9515d04a6e0d186c45f58e09441ba4ff34b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.431/agentshield_0.2.431_linux_amd64.tar.gz"
      sha256 "87eef9fb9b2cfd7727236e0508be66a7bf7a604ab387a3e84a7a605bfa175bf5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.431/agentshield_0.2.431_linux_arm64.tar.gz"
      sha256 "882b579714b2ba9659f6652683aff5ee4a6245ac6cf8be871b3861c3124ea20f"
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
