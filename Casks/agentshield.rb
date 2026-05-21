cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1069"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1069/agentshield_0.2.1069_darwin_amd64.tar.gz"
      sha256 "6478f65f4d747776483090da8ae7b76d39d433c7efc4e3a4f7309b1283e357bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1069/agentshield_0.2.1069_darwin_arm64.tar.gz"
      sha256 "53597144fa1b68c67d3505620639644f6efc85e051477cd5ef8b44742dda1510"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1069/agentshield_0.2.1069_linux_amd64.tar.gz"
      sha256 "69565e480bdae32605dc92fdc9adb31fbcec298b6a1b7687076dfb327a2b8724"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1069/agentshield_0.2.1069_linux_arm64.tar.gz"
      sha256 "49613e1464fd11a149f2f5e2121fef0395a5bcd1308daad21460031a6b970260"
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
