cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1177"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1177/agentshield_0.2.1177_darwin_amd64.tar.gz"
      sha256 "8783d384b2e17d7ec46669285df969165475adb229cd4ec1eeb472ffd500a313"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1177/agentshield_0.2.1177_darwin_arm64.tar.gz"
      sha256 "6e1c89775ebdb144739772ee7e10230b0130f11f4b2f550928e334161d0714e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1177/agentshield_0.2.1177_linux_amd64.tar.gz"
      sha256 "abce0f4e6908544a125d6079e3e3b1b032f3ecadc3b71946e86e438b28ed80e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1177/agentshield_0.2.1177_linux_arm64.tar.gz"
      sha256 "84ff62d9dafb11e7f9ccaab703e52037c03f761daebb5d74695c1e85f75d4721"
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
