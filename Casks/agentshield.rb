cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.216"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.216/agentshield_0.2.216_darwin_amd64.tar.gz"
      sha256 "502ac45864dc8181b04fa8cf1ac47a7d518aeeb6f14e0af3b5e48c7f7b83d34a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.216/agentshield_0.2.216_darwin_arm64.tar.gz"
      sha256 "f1de6a30b9b933525c4b04fe5eb47a7ed898319d9b5aac119e5aefa59f6abb6f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.216/agentshield_0.2.216_linux_amd64.tar.gz"
      sha256 "d499b2f84d20b2258da7f46a6ffbe52a4f9e55f0cefca592f476704d2d73f918"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.216/agentshield_0.2.216_linux_arm64.tar.gz"
      sha256 "110c85edf0962b591f660ed9c374182d4c6b06a2f98ae4d9273e7279050a7753"
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
