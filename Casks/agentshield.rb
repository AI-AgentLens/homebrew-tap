cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.208"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.208/agentshield_0.2.208_darwin_amd64.tar.gz"
      sha256 "63125048a6c67f973428a3a38ba9c10e199349f69aade3bde73a56d606aa6b26"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.208/agentshield_0.2.208_darwin_arm64.tar.gz"
      sha256 "f3e5cbe12a1b8b5df312fca5f3fc7e52d060b16672bf617f226552e9f83ca180"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.208/agentshield_0.2.208_linux_amd64.tar.gz"
      sha256 "947da87f11c75b88998ee5c77120bdc9cee0d4e56ee76302908cc52064e3a971"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.208/agentshield_0.2.208_linux_arm64.tar.gz"
      sha256 "474be8414455bd4ca16bd17c710c448af87dd9d9d6a387f8035b976c390f6873"
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
