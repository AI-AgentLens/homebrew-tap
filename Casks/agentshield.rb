cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2470"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2470/agentshield_0.2.2470_darwin_amd64.tar.gz"
      sha256 "0abfb55dfd18e4d46398a6649ae117a8fda3311c7ebd7714c51672ea57af7ec1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2470/agentshield_0.2.2470_darwin_arm64.tar.gz"
      sha256 "96ad083679f8fcad041b37b99fb1da0d895c235f3ea1fef78d52823f2ff08f8a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2470/agentshield_0.2.2470_linux_amd64.tar.gz"
      sha256 "79511c5ed642cc15e81e080519d05973b85b4517322060c9af73924e5d5778b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2470/agentshield_0.2.2470_linux_arm64.tar.gz"
      sha256 "b9f098d37d8c2830f5c715567da4e306ba7dbfc102358dcfe9fe9bab1ef71639"
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
