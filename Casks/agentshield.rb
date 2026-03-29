cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.193"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.193/agentshield_0.2.193_darwin_amd64.tar.gz"
      sha256 "6dd342f394670e5f1fd7a1014af4344dcee4655f9c92a99f4eb8bf961a7b1eaf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.193/agentshield_0.2.193_darwin_arm64.tar.gz"
      sha256 "f960a3cd85c87baa7b93f7f6f21bc47b14249b0161404d6cf1748124d18c3a60"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.193/agentshield_0.2.193_linux_amd64.tar.gz"
      sha256 "4dc56e2b13c731405b1a90947a7ea8453f21d69f45f9edfcea7767e434f45331"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.193/agentshield_0.2.193_linux_arm64.tar.gz"
      sha256 "ad7fdb8cbee7e5a3bf16d193f3743b7611bc40b202caf6063d459c4749076e9c"
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
